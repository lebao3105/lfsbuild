## Linux From Scratch Build Scripts

### Requirements
* Ext4 disk/partition >10GB (at least for a Linux system, btrfs not tested)
* Linux distribution with a package manager installed** (now I use apt on Ubuntu)
* git to clone this repo (or other package if you want)
* A lot of time (this can take more than 3 hours!)
** : You can check for package requirements on scripts/prepare.sh (run sudo ./scripts/parepare.sh checkreq)

### Run
Clone the repo to the mounted target disk/partition folder:
```
git clone https://github.com/lebao3105/lfsbuild.git <path/to/disk>
```
Now run this to show what you can do here:
```
sudo ./scripts/prepare.sh help
```

You can run any files with the following syntax:
```
cd scripts
sudo prepare.sh [options] # Prepare for the build
su - lfs # After prepared, switch to lfs user
[Script] [Options] # Any file you want
```

Here are the files you need to run:
* prepare.sh (run as root/current user with sudo access)
* buildcompiler1.sh (run as lfs user, build essential compiler part 1 - LFS chapter 5)
* build1.sh (also run as lfs user, build on chapter 6)
* buildcompiler2.sh (build essential compilers part 2)
* build2.sh (run in chroot environment, build some packages)
* build3.sh (Build your base system)
* sysconf.sh (Config the system and setup the bootloader)

### Notes
Normally, the disk/partition is mounted on /media/_your_user_name_/_disk_label. You don't need to mount the partition in /mnt like LFS book.

This project based on LFS Book (also BLFS) Development build - which provides nearly latest packages. The stable version now is 11.x series.

You should still take a look on the build operation (like the script asks you a question, or build failed..). This is just a automated scripts but it can't replace you in building your own system.

This script will install a Linux distribution from scratch. I won't remove any data, but you need to backup/move the data to other disks.

You can't run this script on a partition that exist a system.