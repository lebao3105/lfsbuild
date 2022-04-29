#!/bin/bash

# Check for files
source ./misc.sh
checkwhoami
checkpkg binutils
checkpkg gcc 
checkpkg linux
checkpkg glibc

function build_binutils() {
    echo "Starting..."
    cd $LFS/sources && rm -rf binutils-2.38
    tar -xf binutils-2.38.tar.xz
    cd binutils-2.38 && mkdir -v build && cd build
    echo "Start configuring..."
    ../configure --prefix=$LFS/tools \
         --with-sysroot=$LFS \
         --target=$LFS_TGT   \
         --disable-nls       \
         --disable-werror
    if [[ $? == 0 ]]
    then
        echo "Configuration completed. Now making binutils..."
        make
        make install
        if [[ $? == 0 ]]
        then
            echo "Successfully built binutils."
        else
            echo "Something went wrong here while building Binutils. Please try again."
            exit 1
        fi
    else
        echo "Configuration failed! Exiting."
        exit 1
    fi
}

function build_gcc() {
    echo "Starting..."
    cd $LFS/sources 
    rm -rf gcc-11.2.0
    tar -xf gcc-11.2.0.tar.xz
    cd gcc-11.2.0
    tar -xf ../mpfr-4.1.0.tar.xz
    mv -v mpfr-4.1.0 mpfr
    tar -xf ../gmp-6.2.1.tar.xz
    mv -v gmp-6.2.1 gmp
    tar -xf ../mpc-1.2.1.tar.gz
    mv -v mpc-1.2.1 mpc
    case $(uname -m) in
        x86_64)
            sed -e '/m64=/s/lib64/lib/' \
            -i.orig gcc/config/i386/t-linux64
        ;;
    esac
    mkdir -v build
    cd build
    echo "Start configuring..."
    ../configure                  \
        --target=$LFS_TGT         \
        --prefix=$LFS/tools       \
        --with-glibc-version=2.35 \
        --with-sysroot=$LFS       \
        --with-newlib             \
        --without-headers         \
        --enable-initfini-array   \
        --disable-nls             \
        --disable-shared          \
        --disable-multilib        \
        --disable-decimal-float   \
        --disable-threads         \
        --disable-libatomic       \
        --disable-libgomp         \
        --disable-libquadmath     \
        --disable-libssp          \
        --disable-libvtv          \
        --disable-libstdcxx       \
        --enable-languages=c,c++
    if [[ $? == 0 ]]
    then
        echo "Configuration completed. Now making binutils..."
        make
        make install
        if [[ $? == 0 ]]
        then
            cd ..
            cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
                `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
            echo "Successfully built GCC."
        else
            echo "Something went wrong here while building GCC. Please try again."
            exit 1
        fi
    else
        echo "Configuration failed! Exiting."
        exit 1
    fi
}

function linuxheaders() {
    cd $LFS/sources/
    rm -rf linux-5.17.3
    echo "Extracting the package..."
    tar -xf linux-5.17.3.tar.xz 
    cd linux-5.17.3
    echo "Now start building..."
    make mrproper
    make headers
    find usr/include -name '.*' -delete
    rm usr/include/Makefile
    cp -rv usr/include $LFS/usr
    echo "Now at least Linux kernel Headers should be installed. Check the output for more details."
}

function build_glibc() {
    cd $LFS/sources
    rm -rf glibc-2.35
    tar -xf glibc-2.35.tar.xz
    cd glibc-2.35
    echo "Starting build..."
    case $(uname -m) in
        i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
        ;;
        x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
                ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
        ;;
    esac
    patch -Np1 -i ../glibc-2.35.fhs-1.patch
    mkdir -v build
    cd build
    echo "rootsbindir=/usr/sbin" > configparms
    ../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=3.2                \
      --with-headers=$LFS/usr/include    \
      libc_cv_slibdir=/usr/lib
    if [[ $? == 0 ]]
    then
        echo "Configuration completed. Making..."
        make
        make DESTDIR=$LFS install
        if [[ $? == 0 ]]
        then
            echo "Installed Glibc"
            sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd
        else
            echo "Glibc installation failed! Exiting."
            exit 1
        fi
    else
        echo "Configuration failed!"
        exit 1
    fi
}

function build_libstdcpp() {
    cd $LFS/sources/
    rm -rf gcc-11.2.0
    tar -xf gcc-11.2.0.tar.xz
    cd gcc-11.2.0
    mkdir -v build && cd build
    ../libstdc++-v3/configure           \
        --host=$LFS_TGT                 \
        --build=$(../config.guess)      \
        --prefix=/usr                   \
        --disable-multilib              \
        --disable-nls                   \
        --disable-libstdcxx-pch         \
        --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/11.2.0
    if [[ $? == 0 ]]
    then
        echo "Configure completed. Now making the package..."
        make 
        make DESTDIR=$LFS install
        if [[ $? == 0 ]]
        then 
            echo "Installation completed!"
        else
            echo "Libstdc++ installation failed! Exiting."
            exit 1
        fi
    else
        echo "Configuration failed!"
        exit 1
    fi
}

if [[ $1 == "gcc" ]]
then
    build_gcc
    exit 0
elif [[ $1 == "binutils" ]]
then
    build_binutils
    exit 0
elif [[ $1 == "linux-headers" ]]
then
    linuxheaders
    exit 0
elif [[ $1 == "glibc" ]]
then
    build_glibc
    exit 0
elif [[ $1 == "libstdcpp" ]]
then 
    build_libstdcpp
    exit 0
elif [[ $1 == "all" ]]
then
    build_binutils
    build_gcc
    linuxheaders
    build_libstdcpp
    exit 0
fi