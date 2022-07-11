#!/bin/bash

# Ask for $LFS
function askpart() {
    echo "Enter mounted partition location : "
    read ans
    if [[ "$ans" == "" ]]
    then
        echo "No input found."
        # *exit*
        exit
    else
        df -t ext4 || df -t btrfs | grep "$ans" > /dev/null 2>&1
        if [[ $? == 0 ]]
        then
            export LFS="$ans"
        else
            echo "$ans may not a Ext4/Btrfs partition, or the partition is not mounted."
            exit 1
        fi
    fi   
}

# Check if $LFS is defined or not
function noname() {
    if [[ $LFS == "" ]]
    then
        askpart
        break
    else # or not:)
        checksys
        break
    fi
}

# Check if we running script as lfs user
function checkwhoami() {
    if ! [ $(whoami) == "lfs" ]
    then
        echo "Please run this script as lfs user. This is required!"
        exit 1
    else 
        # also checking the file system
        if [[ $LFS == "" ]]
        then 
            redcolor "LFS not setted up! Please run prepare.sh before go further!"
            exit 1
        else
            checksys
        fi
    fi
}

# Check the LFS system
function checksys() {
    if [ -d $LFS/{usr/{,bin,lib,sbin},lib,var,etc,bin,sbin,tools,sources} ]
    then
        redcolor "Warning: Is this location - $LFS - LFS system?"
        redcolor "If NOT, run prepare.sh first!"
        exit 1
    fi
}

# Check if we have our needed files
function checkpkg() {
    ls $LFS/sources/ | grep $1 > /dev/null 2>&1
    if [[ $? == 0 ]]
    then
        greencolor "$1 found."
        for in in $(ls -d $LFS/sources/*/ | grep $1); do
            rm -rf ${i%%/}
        done
        tar -xf $1*.tar*
        if [[ $? == 0 ]]
        then
            break
        else
            redcolor "Source code of $1 cannot be extracted!"
            exit 1
        fi
        break
    else
        redcolor "$1 not found. Run ./prepare.sh getpkgs to get all required packages."
        exit 1
    fi
}

# Text colors
function redcolor() {
    printf "\033[31m%s\033[0m" "$@"
}

function greencolor() {
    printf "\033[32m%s\033[0m" "$@"
}

# Build style(s)
function style1() {
    ./configure --prefix=/usr --host=$LFS_TGT \
                "$@"
    if [[ $? == 0 ]]
    then
        greencolor "Now making the package..."
        install
        break
    else 
        redcolor "Configuration failed!"
        exit 1
    fi
}

# for new system before be chrootted
function install() {
    make 
    make DESTDIR=$LFS install
    if [[ $? == 0 ]]
    then
        greencolor "Done!"
    else 
        redcolor "Installation of a package failed!"
        exit 1
    fi
}

# for chrootted system
function install_chrootted() {
    make
    # some time we need to test the package
    if [[ $@ == "check" ]]; then
        make check
    elif [[ $@ == "test" ]]; then
        make test
    fi
    make install
}

function check_chroot() {
    # Check if the script is running as root
    if [[ $EUID -ne 0 ]]
    then
        echo "This script must be run as root"
        exit 1
    fi

    # Check if we are in chroot environment
    if [[ $(ls /sources) != "" ]]
    then
        echo "This script must be run inside chroot environment"
        exit 1
    fi
}