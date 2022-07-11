## Linux From Scratch Build Scripts

### Requirements
* A partition that is higher than 10GB (for normal use) or ~6GB (for testing if this project works:)
* Install required packages shown from [scripts/checker.sh --list-pkgs](scripts/checker.sh)
* User with sudo access (or even running as **root** user)
* A working internet for running [scripts/prepare.sh](scripts/prepare.sh) (if you don't use all-nodown parameter)
* bash

### Run
Clone this project, then run this to show what you can do here:
```
sudo bash -x ./scripts/prepare.sh help
```

You can run any files with the following syntax:
```
cd scripts
sudo bash -x prepare.sh [options] # If you have not done this yet
su - lfs # After prepared, switch to lfs user
bash -x [Script] [Options] # Any file you want
```
Some files are required to run as root, take care about that.

Here are the files you need to run:
* prepare.sh (run as root/current user with sudo access)
* buildcompiler1.sh (run as lfs user, build essential compiler part 1 - LFS chapter 5)
* build1.sh (also run as lfs user, build on chapter 6)
* buildcompiler2.sh (build essential compilers part 2)
* build2.sh (run in chroot environment, build some packages)
* build2_5.sh (part 2 of the build2.sh script)
* build3.sh (Build your base system)

### Notes
Normally, the disk/partition is mounted on a folder namely its label/UUID under ```/media/$USER/```. You don't need to mount the partition in /mnt like LFS book.

This project based on LFS Book (also BLFS) Development build - which provides nearly latest packages. The stable version is 11.x series.

This script will install a Linux distribution from scratch. Backup your data, and make a partition.<br>
ALL data on the new partition WILL BE DESTROYED. Make sure to format it to Ext4/Btrfs format. Never use NTFS or FAT!

This will takes you a lot of times (building GCC and Binutils + Linux kernel are the longests). You can do something you need, e.g your homeworks. But still look your PC.
