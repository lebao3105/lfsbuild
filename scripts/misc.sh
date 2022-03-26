#!/bin/sh

# Ask for $LFS
function askpart() {
    echo "Enter mounted partition location : "
    read ans
    if [[ "$ans" == "" ]]
    then
        echo "No input found."
        exit
    else
        df -t ext4 | grep "$ans" > /dev/null 2>&1 # Check if the partition is mounted or used as Ext4 disk
        if [[ $? == 0 ]]
        then
            export LFS="$ans"
        else
            echo "$ans may not a Ext4 partition, or the partition is not mounted."
            echo "You need to format the partition to Ext4 file system, or mount the partition."
            exit 1
        fi
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
    if [ -d $LFS/{usr/{,bin,lib,sbin},lib} ]
    then
        redcolor "LFS file system not found! Run prepare.sh mkdirs to make required folders."
        exit 1
    fi
    if [ -d $LFS/{var,etc,bin,sbin,tools,sources} ]
    then
        redcolor "LFS file system not found! Run prepare.sh mkdirs to make required folders."
            exit 1
    fi
}

function checkpkg() {
    ls $LFS/sources/ | grep $1 > /dev/null 2>&1
    if [[ $? == 0 ]]
    then
        greencolor "$1 found."
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

# Build styles
function style1() {
    ./configure --prefix=/usr --host=$LFS_TGT \
                "$@"
    if [[ $? == 0 ]]
    then
        greencolor "Now making the package..."
        break
    else 
        redcolor "Configuration failed!"
        exit 1
    fi
}

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
