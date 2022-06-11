#!/bin/bash

# This script is not completed yet,
# and it based on LFS chapter 8, which builds a lot of packages.
# Part 1 - build man-pages to mpfr.

# Important notes: I will check for ALL packages build steps to choose which
# items are using the same command(s).

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

function ins_man() {
    cd $LFS/sources/
    rm -rf man-pages-5.13
    tar -xf man-pages-5.13.tar.xz
    cd man-pages-5.13
    make prefix=/usr install
}

function ins_ianaetc() {
    cd $LFS/sources/ && rm -rf iana-etc-20220524
    tar -xf iana-etc-20220524.tar.xz
    cd iana-etc-20220524
    cp services protocols /etc
}
}
