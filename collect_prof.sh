#!/usr/bin/env bash

set -e

if [ $# -ne 3 ]; then
    echo "Please pass three arguments."
    exit 1
fi

CPATH="$1"
$CPATH/clang --version > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Error: Not $CPATH not Path to clang. Please provide path to clang binary (e.g /usr/bin)."
    exit 1
fi

# Shifting argument because we don't need to use this later.
shift 1

process_directory() {
    flag="$1"
    dir="$2"

    if ! [ -d "$dir" ]; then
        echo "Error: $dir not a directory."
        exit 1
    fi

    if [ -z "$(find "$dir" -name "*.data" -print -quit)" ]; then
        echo "Error: $dir does not have any .data file."
        exit 1
    fi
    
    case $flag in
        -n)
            echo "in nlbr."
            ;;
        -l)
            echo "in lbr."
            ;;
        -pt)
            echo "in pt."
            ;;
        *)
            echo "not supported flag."
            exit 1
            ;;
    esac
}

while [ $# -gt 1 ]; do
    flag="$1"
    dir="$2"

    process_directory "$flag" "$dir"
    shift 2
done


