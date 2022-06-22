#!/bin/bash
# Prepare for building our LFS system : Get a partition and get packages
# Make sure to read README.md & run ./checker.sh first!

source ./misc.sh # import first

function mkdirs() {
    askpart
    echo "Making directories..."
    mkdir -pv $LFS/{usr,lib,var,etc,bin,sbin,tools,sources} 
    mkdir -pv $LFS/usr/{bin,lib,sbin}
    chmod a+wt $LFS # fix permission denied error while logged in as lfs
    chmod a+wt $LFS/sources/
    for i in bin lib sbin; do
        ln -sv usr/$i $LFS/$i 
    done

    case $(uname -m) in
        x86_64) mkdir -pv $LFS/lib64 ;;
    esac
}

function getpkgs() {
    echo "Downloading packages... Look for wget-list first"
    if [[ -f "wget-list" ]];
    then
        echo "Exists!"
        break
    else
        echo "Package list not exist in the file system. Getting it..."
        # We have this file already, but if it's not exists, get it
        if [[ command -v wget >/dev/null 2>&1 ]]
        then
            wget http://www.linuxfromscratch.org/lfs/view/development/wget-list
        else
            echo "Both wget and curl not found!"
            exit 1
        fi
    fi
    wget -i wget-list -c --show-progress -P $LFS/sources
    if [[ $? == 0 ]]
    then
        echo "Package downloaded successfully."
    fi
}

function makeuser() {
    # Check if there are a user named lfs before
    ls /home/ | grep lfs > /dev/null 2>&1
    if ! [[ $? == 0 ]]
    then
        echo "Now the script will create a user named lfs."
        echo "Set it a password after user created."
        groupadd lfs
        useradd -s /bin/bash -g sudo -m -k /dev/null lfs
        passwd lfs
        break
    fi
    echo "Now give lfs permission..."
    chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools,sources}
    case $(uname -m) in
        x86_64) chown -v lfs $LFS/lib64 ;;
    esac
    echo "Applying configurations..."
    rm /home/lfs/.bash{_profile,rc} # Remove old configurations
    echo 'exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash' >> /home/lfs/.bash_profile
    echo 'set +h
        umask 022
        LFS='$LFS >> /home/lfs/.bashrc
    echo 'LC_ALL=POSIX
        LFS_TGT=$(uname -m)-lfs-linux-gnu
        PATH=/usr/bin
        if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
        PATH=$LFS/tools/bin:$PATH
        CONFIG_SITE=$LFS/usr/share/config.site
        export LFS LC_ALL LFS_TGT PATH CONFIG_SITE' >> /home/lfs/.bashrc
    echo "Now everything should be done here. Do su - lfs to login to lfs user and do something other."
}

function header() {
    echo "Linux From Scratch (LFS) System Development Build Script"
    echo "by lebao3105 - use for development only."
    echo "use help for list all commands to use here."
    echo "--------------------------------------------------------"
}

if [[ $1 -ne "help"]]; then
    # Check if the script is running as root
    if [[ $EUID -ne 0 ]]; then
        redcolor "This script must be run as root" 1>&2
        exit 1
    fi
fi

# Main program 
if [[ $1 == "mkdir" ]]
then
    header
    mkdirs
elif [[ $1 == "download" ]]
then
    header
    getpkgs
<< ENC
'M4-1.4.10
Make-4.0
Patch-2.5.4
Perl-5.8.8
Python-3.4
Sed-4.1.5
Tar-1.22
Texinfo-4.7
Xz-5.0.0
Bash-3.2 (/bin/sh should be a symbolic or hard link to bash)
Binutils-2.13.1 (version 2.38+ are not tested)
Bison-2.7 (/usr/bin/yacc should be a link to bison or small script that executes bison)
Coreutils-6.9
Diffutils-2.8.1
Findutils-4.2.31
Gawk-4.0.1 (/usr/bin/awk should be a link to gawk)
GCC-4.8 including the C++ compiler, g++ (Versions greater than 11.2.0 are not recommended as they have not been tested). C and C++ standard libraries (with headers) must also be present so the C++ compiler can build hosted programs
Grep-2.5.1a
Gzip-1.3.12
Linux Kernel-3.2'
ENC
elif [[ $1 == "createuser" ]]
then
    header
    makeuser
elif [[ $1 == "" ]]
then
    header
    echo "Some available commands:"
    echo "createuser : Make user for building"
    echo "download : Get packages"
    echo "mkdir : Make system directories"
    echo "all : Make everything"
    echo "all-nodown : Make everything without downloading"
    echo "Why you get there? - You are missing one of theese commands."
    exit 1
elif [[ $1 == "all" ]] # do everything
then
    header
    mkdirs
    getpkgs
    check_req
    makeuser
elif [[ $1 == "all-nodown" ]] # do everything but not download
then
    header
    mkdirs
    check_req
    makeuser
fi

