#!/bin/bash
# Build compilers part 2 - end of LFS chapter 6
# This file is not tested yet. I made it by hand.
# Always use bash -x to run the scripts.

source ./misc.sh

checkwhoami
checkpkg binutils
checkpkg gcc
checkpkg mpfr
checkpkg gmp
checkpkg mpc

function build_gcc() {
    cd $LFS/sources
    cd gcc-11.2.0
    
    # Extract mpfr, gmp and mpc
    mv -v ../mpfr-4.1.0 mpfr
    mv -v ../gmp-6.2.1 gmp
    mv -v ../mpc-1.2.1 mpc

    # Configure & add some fixes
    case $(uname -m) in
    x86_64)
        sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
    ;;
    esac

    sed 's/gnu++17/& -nostdinc++/' \
        -i libstdc++-v3/src/c++17/Makefile.in

    sed '/thread_header =/s/@.*@/gthr-posix.h/' \
        -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in
    
    mkdir -v build
    cd build
    echo "Start configuring..."
    style1 --build=$(../config.guess)                  \
        --target=$LFS_TGT                              \
        LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc      \
        --with-build-sysroot=$LFS                      \
        --enable-initfini-array                        \
        --disable-nls                                  \
        --disable-multilib                             \
        --disable-decimal-float                        \
        --disable-libatomic                            \
        --disable-libgomp                              \
        --disable-libquadmath                          \
        --disable-libssp                               \
        --disable-libvtv                               \
        --enable-languages=c,c++
    if [[ $? == 0 ]]
    then
        echo "Configuration completed. Now making binutils..."
        make
        make DESTDIR=$LFS install
        if [[ $? == 0 ]]
        then
            cd ..
            cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
                `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
            ln -sv gcc $LFS/usr/bin/cc
            echo "Successfully built and install GCC."
        else
            echo "Failed to build GCC."
            exit 1
        fi
    else
        echo "Configuration failed! Exiting."
        exit 1
    fi
}

function build_binutils() {
    cd $LFS/sources
    cd binutils-2.38
    mkdir -v build
    cd build
    sed '6009s/$add_dir//' -i ../ltmain.sh
    style1 --build=$(../config.guess) \
        --disable-nls              \
        --enable-shared            \
        --disable-werror           \
        --enable-64-bit-bfd
    if [[ $? == 0 ]]
    then
        echo "Configuration completed. Now making binutils..."
        make
        make DESTDIR=$LFS install
        if [[ $? == 0 ]]
        then
            echo "Successfully built and install binutils."
        else
            echo "Failed to build binutils."
            exit 1
        fi
    else
        echo "Configuration failed! Exiting."
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
elif [[ $1 == "all" ]]
then
    build_binutils
    build_gcc
    exit 0
else
    echo "Please specify either 'gcc' or 'binutils' or 'all' as an argument."
    exit 1
fi
