#!/bin/bash
# Build 2 script part 2 - started on LFS 7.7+.
# Run as root - LFS system
# This script is not tested!

source ./misc.sh
checkpkg "gettext"
checkpkg "bison"
checkpkg "perl"
checkpkg "python"
checkpkg "texinfo"

check_chroot

function build_gettext() {
    greencolor "Building gettext..."
    cd /sources
    rm -rf gettext-0.21
    tar -xf gettext-0.21.tar.xz
    cd gettext-0.21
    ./configure --prefix=/usr --docdir=/usr/share/doc/gettext-0.21 --disable-shared
    if [[ $? -ne 0 ]]
    then
        redcolor "Error: gettext-0.21 failed to configure"
        exit 1
    else
        make
        if [[ $? -ne 0 ]]
        then
            redcolor "Error: gettext-0.21 failed to make"
            exit 1
        else
            greencolor "Installing gettext documents..."
            cp -v doc/{examples,html,info,install-guide,pdf,xml} /usr/share/doc/gettext-0.21
            greencolor "Installing gettext..."
            cp -v gettext-tools/src/{catgets,gettext.h,gettextconfig.h,gettext.pc} /usr/include
            cp -v gettext-tools/bin/{msgfmt,msgmerge,xgettext} /usr/bin
            if [[ $? -ne 0 ]]
            then
                redcolor "Error: gettext-0.21 failed to install"
                exit 1
            fi
        fi
    fi
}

function build_bison() {
    greencolor "Building bison..."
    cd /sources
    rm -rf bison-3.8.2
    tar -xf bison-3.8.2.tar.xz
    cd bison-3.8.2
    ./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2
    if [[ $? -ne 0 ]]
    then
        redcolor "Error: bison-3.0.4 failed to configure"
        exit 1
    else
        make
        if [[ $? -ne 0 ]]
        then
            redcolor "Error: bison-3.8.2 failed to run make"
            exit 1
        else
            greencolor "Installing bison..."
            make install
            if [[ $? -ne 0 ]]
            then
                redcolor "Error: bison-3.8.2 failed to install"
                exit 1
            fi
        fi
    fi
}

function build_perl() {
    greencolor "Start building perl..."
    cd /sources
    rm -rf perl-5.34.1
    tar -xf perl-5.34.1.tar.xz
    cd perl-5.34.1
    sh Configure -des                                        \
             -Dprefix=/usr                               \
             -Dvendorprefix=/usr                         \
             -Dprivlib=/usr/lib/perl5/5.34/core_perl     \
             -Darchlib=/usr/lib/perl5/5.34/core_perl     \
             -Dsitelib=/usr/lib/perl5/5.34/site_perl     \
             -Dsitearch=/usr/lib/perl5/5.34/site_perl    \
             -Dvendorlib=/usr/lib/perl5/5.34/vendor_perl \
             -Dvendorarch=/usr/lib/perl5/5.34/vendor_perl
    if [[ $? -ne 0 ]]
    then
        redcolor "Error: perl-5.34.1 failed to configure"
        exit 1
    else
        make
        if [[ $? -ne 0 ]]
        then
            redcolor "Error: perl-5.34.1 failed to make"
            exit 1
        else
            make install
            if [[ $? -ne 0 ]]
            then
                redcolor "Error: perl-5.34.1 failed to install"
                exit 1
            fi
        fi
    fi
}

function build_py() {
    # Do something...
}

function build_texinfo() {
    # Do stuff
}

function build_utilinux () {

}

if [[ $1 == "gettext" ]]
then
    build_gettext
elif [[ $1 == "bison" ]]
then
    build_bison
elif [[ $1 == "perl" ]]
then
    build_perl
elif [[ $1 == "py" ]]
then
    build_py
elif [[ $1 == "texinfo" ]]
then
    build_texinfo
elif [[ $1 == "utilinux" ]]
then
    build_utilinux
elif [[ $1 == "all" ]]
then
    build_gettext
    build_bison
    build_perl
    build_py
    build_texinfo
    build_utilinux
else
    echo "Usage: $0 [gettext|bison|perl|py|texinfo|utilinux|all]"
fi



