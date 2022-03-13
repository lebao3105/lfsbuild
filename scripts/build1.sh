#!/bin/sh
# This based on Chapter 6 in LFS
# Check for packages
source ./misc.sh
checkwhoami
checkpkg m4
checkpkg ncurses
checkpkg bash
checkpkg coreutils
checkpkg diffutils
checkpkg file
checkpkg findutils
checkpkg gawk
checkpkg grep
checkpkg gzip
checkpkg make
checkpkg patch
checkpkg sed
checkpkg tar
checkpkg xz

function m4_inst () {
    echo "Building m4..."
    cd $LFS/sources
    rm -rf m4-1.4.19
    tar -xf m4-1.4.19.tar.xz
    cd m4-1.4.19
    style1 "--build=$(build-aux/config.guess)"
    install
}

function ncurses_inst () {
    echo "Building ncurses"
    cd $LFS/sources
    rm -rf ncurses-6.3
    tar -xf ncurses-6.3.tar.gz
    cd ncurses-6.3
    sed -i s/mawk// configure
    mkdir build
    pushd build
      ../configure 
      make -C include
      make -C progs tic
    popd
    ./configure --prefix=/usr        \
        --host=$LFS_TGT              \
        --build=$(./config.guess)    \
        --mandir=/usr/share/man      \
        --with-manpage-format=normal \
        --with-shared                \
        --without-debug              \
        --without-ada                \
        --without-normal             \
        --disable-stripping          \
        --enable-widec
    if [[ $? == 0 ]]
    then
        greencolor "Configuration succuded. Now launching make.."
        make
        make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
        if [[ $? == 0 ]]
        then
            greencolor "Installation completed!"
            echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
        else
            redcolor "Error(s) occured while installing Ncurses. Please try again."
            exit 1
        fi
    else
        redcolor "Configuration failed!"
        exit 1
    fi
}

function bash_inst () {
    echo "Start building..."
    cd $LFS/sources
    rm -rf bash-5.1.16
    tar -xf bash-5.1.16.tar.gz
    cd bash-5.1.16
    style1 "--build=$(support/config.guess) --without-bash-malloc"
    install
    ln -sv bash $LFS/bin/sh
}

function coreutils_inst () {
    echo "Start building..."
    cd $LFS/sources
    rm -rf coreutils-9.0
    tar -xf coreutils-9.0.tar.xz
    cd coreutils-9.0
    style1 "--build=$(build-aux/config.guess) --enable-install-program=hostname --enable-no-install-program=kill,uptime"
    install
    mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin
    mkdir -pv $LFS/usr/share/man/man8
    mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
    sed -i 's/"1"/"8"/'                    $LFS/usr/share/man/man8/chroot.8
}

function diff_inst () {
    cd $LFS/sources
    rm -rf diffutils-3.8
    tar -xf diffutils-3.8.tar.xz
    cd diffutils-3.8
    style1 ""
    install
}

function file_inst () {
    echo "Starting building..."
    cd $LFS/sources
    rm -rf file-5.41
    tar -xf file-5.41.tar.gz
    cd file-5.41
    mkdir build
    pushd build
    ../configure --disable-bzlib      \
                   --disable-libseccomp \
                   --disable-xzlib      \
                   --disable-zlib
    make
    popd
    style1 "--build=$(./config.guess)"
    make FILE_COMPILE=$(pwd)/build/src/file
    make DESTDIR=$LFS install
}

function find_inst() {
    cd $LFS/sources
    rm -rf findutils-4.9.0
    tar -xf findutils-4.9.0.tar.xz
    cd findutils-4.9.0
    style1 "--localstatedir=/var/lib/locate --build=$(build-aux/config.guess)"
    install
}

function gawk_inst() {
    cd $LFS/sources
    rm -rf gawk-5.1.1
    tar -xf gawk-5.1.1.tar.xz
    cd gawk-5.1.1
    style1 "--build=$(build-aux/config.guess)"
    install
}

function grep_inst() {
    cd $LFS/sources/
    rm -rf grep-3.7
    tar -xf grep-3.7.tar.xz
    cd grep-3.7
    style1 ""
    install
}

function gzip_inst() {
    cd $LFS/sources
    rm -rf gzip-1.11
    tar -xf gzip-1.11.tar.xz
    cd gzip-1.11
    style1 ""
    install
}

function make_inst() {
    cd $LFS/sources
    rm -rf make-4.3
    tar -xf make-4.3.tar.gz
    cd make-4.3
    style1 "--without-guile --build=$(build-aux/config.guess)"
    install
}

function patch_inst() {
    cd $LFS/sources
    rm -rf path-2.7.6
    tar -xf path-2.7.6.tar.xz
    cd path-2.7.6
    style1 "--build=$(build-aux/config.guess)"
    install
}

function sed_inst() {
    cd $LFS/sources
    rm -rf sed-4.8
    tar -xf sed-4.8.tar.xz
    cd sed-4.8
    style1 ""
    install
}

function tar_inst() {
    cd $LFS/sources
    rm -rf tar-1.34
    tar -xf tar-1.34.tar.xz
    cd tar-1.34
    style1 "--build=$(build-aux/config.guess)"
    install
}

function xz_inst() {
    cd $LFS/sources/
    rm -rf xz-5.2.5
    tar -xf xz-5.2.5.tar.xz
    cd xz-5.2.5
    style1 "--build=$(build-aux/config.guess) --disable-static --docdir=/usr/share/doc/xz-5.2.5"
    install
}

if [[ "$@" == "m4" ]]
then
    m4_inst
elif [[ "$@" == "ncurses" ]]
then
    ncurses_inst
elif [[ "$@" == "bash" ]]
then
    bash_inst
elif [[ "$@" == "coreutils" ]]
then
    coreutils_inst
elif [[ "$@" == "diff" ]]
then
    diff_inst
elif [[ "$@" == "file" ]]
then
    file_inst
elif [[ "$@" == "findutils" ]]
then
    find_inst
elif [[ "$@" == "gawk" ]]
then
    gawk_inst
elif [[ "$@" == "grep" ]]
then
    grep_inst
elif [[ "$@" == "gzip" ]]
then
    gzip_inst
elif [[ "$@" == "make" ]]
then
    make_inst
elif [[ "$@" == "patch" ]]
then
    patch_inst
elif [[ "$@" == "sed" ]]
then
    sed_inst
elif [[ "$@" == "tar" ]]
then
    tar_inst
elif [[ "$@" == "xz" ]]
then
    xz_inst
elif [[ $1 == "all" ]]
then
    m4_inst
    ncurses_inst
    bash_inst
    coreutils_inst
    diff_inst
    file_inst
    find_inst
    gawk_inst
    grep_inst
    gzip_inst
    make_inst
    patch_inst
    sed_inst
    tar_inst
    xz_inst
elif [[ $1 == "help" ]]
then
    echo "Run one of these parameters to install a package:"
    echo "Parameter = these functions below without _inst"
    echo "Use all will build everything."
    echo "m4_inst"
    echo "ncurses_inst"
    echo "bash_inst"
    echo "coreutils_inst"
    echo "diff_inst"
    echo "file_inst"
    echo "findutils_inst"
    echo "gawk_inst"
    echo "grep_inst"
    echo "gzip_inst"
    echo "make_inst"
    echo "patch_inst"
    echo "sed_inst"
    echo "tar_inst"
    echo "xz_inst"
    exit
fi