#!/bin/bash

# This script is not completed yet,
# and it based on LFS chapter 8, which builds a lot of packages.
# Part 1 - build man-pages to mpfr

source ./misc.sh

checkpkg man-pages
checkpkg iana-etc
checkpkg glibc
checkpkg zlib
checkpkg bzip2
checkpkg xz
checkpkg zstd
checkpkg file
checkpkg readline
checkpkg m4
checkpkg bc
checkpkg flex
checkpkg tcl8
checkpkg expect5
checkpkg dejagnu
checkpkg binutils
checkpkg gmp
checkpkg mpfr

check_chroot
# Since we use this, $LFS variable is not needed anymore

function ins_man() {
    cd /sources/
    #rm -rf man-pages-5.13
    #tar -xf man-pages-5.13.tar.xz
    cd man-pages-5.13
    make prefix=/usr install
}

function ins_ianaetc() {
    cd /sources/ 
    #rm -rf iana-etc-20220524
    #tar -xf iana-etc-20220524.tar.xz
    cd iana-etc-20220524
    cp services protocols /etc
}

function ins_glibc() {
    cd /sources/glibc-2.35
    patch -Np1 -i ../glibc-2.35.fsh-1.patch
    mkdir build && cd build
    echo "rootsbindir=/usr/sbin" > configparms
    style1 "--disable-werror --enable-stack-protector=strong \
            --with-headers=/usr/include libc_cv_slibdir=/usr/lib"
    if [[ $? -eq 0 ]]; then
        touch /etc/ls.so.conf
        sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
        install_chrootted "check"
        cp -v ../nscd/nscd.conf /etc/nscd.conf
        mkdir -pv /var/cache/nscd
        make localedata/install-locales
}
