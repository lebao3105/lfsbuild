#!/bin/bash
# This script will run as root and no longer be lfs user.
# Based on LFS chapter 7.

# Check if we running script as root
if [[ $EUID -ne 0 ]]
then
    echo "This script must be run as root"
    exit 1
fi

# Prepare for chroot
function mkdirs() {

    echo "Creating folders..."
    
    mkdir -pv $LFS/{boot,home,mnt,opt,srv}
    mkdir -pv $LFS/etc/{opt,sysconfig}
    mkdir -pv $LFS/lib/firmware
    mkdir -pv $LFS/media/{floppy,cdrom}
    mkdir -pv $LFS/usr/{,local/}{include,src}
    mkdir -pv $LFS/usr/local/{bin,lib,sbin}
    mkdir -pv $LFS/usr/{,local/}share/{color,dict,doc,info,locale,man}
    mkdir -pv $LFS/usr/{,local/}share/{misc,terminfo,zoneinfo}
    mkdir -pv $LFS/usr/{,local/}share/man/man{1..8}
    mkdir -pv $LFS/var/{cache,local,log,mail,opt,spool}
    mkdir -pv $LFS/var/lib/{color,misc,locate}

    echo "Then link some files..."
    ln -sfv $LFS/run $LFS/var/run
    ln -sfv $LFS/run/lock $LFS/var/lock
    ln -sv $LFS/proc/self/mounts $LFS/etc/mtab

    install -dv -m 0750 $LFS/root
    install -dv -m 1777 $LFS/tmp $LFS/var/tmp
}

function setup_more() {
    greencolor "Creating some files in $LFS/etc..."
    cp -v ../templates/* $LFS/etc/
    greencolor "Now create some files in $LFS/var/log..."
    touch /var/log/{btmp,lastlog,faillog,wtmp}
    chgrp -v utmp /var/log/lastlog
    chmod -v 664  /var/log/lastlog
    chmod -v 600  /var/log/btmp
}

function go_chroot() {
    echo "Checking if chroot needs to run with sudo..."
    pause 5
    chroot > /dev/null 2>&1
    if [[ $? == 0 ]]
    then
        greencolor "Chroot needs to run with sudo."
        echo "Now running chroot..."
        su = "sudo -i"
        break
    else
        greencolor "Chroot does not need to run with sudo."
        echo "Now running chroot..."
        su = ""
        break
    fi
    $(su) chroot $LFS /tools/bin/env -i \
            HOME=/root TERM=$TERM PS1='\u:\w\$ ' \
            PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
            /tools/bin/bash --login +h
    if [[ $? == 0 ]]
    then
        greencolor "Chroot done."
        exit 0
    else
        redcolor "Chroot failed."
        exit 1
    fi
}

function chroot_setup() {
    echo "Starting operations... This will take a time."
    chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
    case $(uname -m) in
        x86_64) chmod -R root:root $LFS/lib64 ;;
    esac

    mkdir -pv $LFS/{dev,proc,sys,run}
    # Now let's mount the file systems
    echo "Mouting file systems..."
    mount -v --bind /dev $LFS/dev
    mount -vt devpts devpts $LFS/dev/pts -o gid=5,mode=620
    mount -vt proc proc $LFS/proc
    mount -vt sysfs sysfs $LFS/sys
    mount -vt tmpfs tmpfs $LFS/run

    if [[ $? == 0 ]]
    then
        greencolor "File systems mounted. Now going to run chroot..."
        if [ -h $LFS/dev/shm ]; then
            mkdir -pv $LFS/$(readlink $LFS/dev/shm)
        fi
        ln -sv $LFS/proc/self/mounts $LFS/etc/mtab
        break
    else
        redcolor "File systems not mounted."
        exit 1
    fi

    setup_more
}

# Args
if [[ $1 == "--help" ]]
then
    echo "Usage: sudo ./build2.sh [--help]"
    echo "This script will run as root and no longer be lfs user."
    echo "Based on LFS chapter 7."
    echo "Targets:"
    echo "  --help    Show this help message and exit"
    echo "  --chroot  chroot into the LFS environment"
    echo "  --mkdirs  Make more addititional folders that prepare.sh don't want to do it"
    echo "  --setup   Setup more things in the LFS environment, including mount files system on $LFS"
    echo "  --auto-run-next   Run the next script (build2_5.sh) automatically"
    exit 0
elif [[ $1 == "--chroot" ]]
then
    askpart
    checksys
    chroot_setup
    go_chroot
elif [[ $1 == "--mkdirs" ]]
then
    askpart
    checksys
    mkdirs
elif [[ $1 == "--setup" ]]
then
    askpart
    checksys
    mkdirs
    chroot_setup
elif [[ $1 == "--auto-run-next" ]]
then
    echo "There are no more new scripts to run, but you can do go chroot first."
    askpart
    checksys
    mkdirs
    chroot_setup
    go_chroot
fi