#!/bin/bash
if [[ $1 == "--list-pkgs" ]]
then
    cat << EOF
    "* Required packages:
    m4 make patch perl python (version 3) sed tar xz bash binutils gcc (including C++ compilers)
    bison coreutils diffutils findutils gawk grep gzip wget (to get wget-list, if needed)
    * Something else like:
    - User that can use sudo or have access to root account
    - Linux kernel should be higher than 4.x series. Running a (nearly) recent Linux distros can help.
    - A stable and normal internet connection is required while running prepare.sh without all-nodown parameter.
    "
EOF
elif [[ $1 == "--help" ]]
then
    echo "$0 [parameters]"
    echo "--help : show this help and exit"
    echo "--checkfs : Check for the file system of the target partition"
    echo "--list-pkgs : List required packages and other requirements"
    echo "Running $0 with no/invalid parementers will start the checker."
    exit 1
else
    export LC_ALL=C
    echo "Start checking... It is very fast."
    # Make arrays.
    arr=(
        gcc g++ bash ld bison chown diff find gawk 
        grep gzip m4 make patch perl python3 sed 
        tar xz wget
    )
    another_arr=(awk yacc)
    notfound=() # not installed commands
    found=() # also installed

    for i in ${arr[@]}; do
        command -v $i >/dev/null 2>&1
        if [[ $? == 1 ]]; then
            notfound+=($i)
        else
            found+=($i)
        fi
    done

    for k in ${another_arr[@]}; do
        if [ -h /usr/bin/$k ]; then
            echo "/usr/bin/$k pointed to `readlink -f /usr/bin/$k`";
        elif [ -x /usr/bin/$k ]; then
            found+=($k)
        else
            notfound+=($k)
        fi
    done

    echo "Result:"
    echo "Installed packages:"
    for j in ${found[@]}; do
        echo "* $j"
    done

    echo "Missing packages:"
    for l in ${notfound[@]}; do
        echo "* $l"
    done
    echo "Done!"
    exit 0
fi