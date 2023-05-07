#!/usr/bin/env bash

# This script uses collected profiles (from /path/to/profiles), uses perf2bolt to
# convert them into bolt format profiles and uses llvm-bolt to emit optimized
# clang binary.

set -e

if [ $# -ne 5 ]; then
    echo "Please pass correct number of arguments. Usage: ./collect_prof
    /path/to/clang -o output_directory -n nolbr_profiles."
    exit 1
fi

CPATH="$1"
$CPATH/clang --version > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Error: Not $CPATH not Path to clang. Please provide path to clang
    binary (e.g /usr/bin)." 
    exit 1
fi

# Shifting argument because we don't need to use this later.
shift 1

output_flag="$1"
output_directory="$2"

if [ "$output_flag" != "-o" ]; then
    echo "Missing -o flag!"
    exit 1
fi

shift 2

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
            echo "Checking .data files in $dir"
            for data_file in $(find "$dir" -name "*.data"); do
                if [ -d "$output_directory"]; then
                    read -p "$output_directory directory already exists, continue? (y/n)" answer
                    if [ $answer = "n"]; then
                        exit 1
                    fi
                else 
                    mkdir -p "$output_directory"
                fi
                base_name="${data_file%.data}"
                perf2bolt "$CPATH/clang-16" --nl -p "$data_file" -o "$output_directory/${base_name}.fdata" -w "$output_directory/${base_name}.yaml"
            done
            ;;
        -l)
            echo "Checking .data files in $dir"
            for data_file in $(find "$dir" -name "*.data"); do
                if [ -d "$output_directory"]; then
                    read -p "$output_directory directory already exists, continue? (y/n)" answer
                    if [ $answer = "n"]; then
                        exit 1
                    fi
                else 
                    mkdir -p "$output_directory"
                fi
                base_name="${data_file%.data}"
                perf2bolt "$CPATH/clang-16" -p "$data_file" -o "$output_directory/${base_name}.fdata" -w "$output_directory/${base_name}.yaml"
            done
            ;;
        -pt)
            echo "Checking .data files in $dir"
            for data_file in $(find "$dir" -name "*.data")]; do
                if [$(perf script -i "$data_file" --itrace=e | grep -q "instruction trace error"); then
                    echo "Error: instruction trace error found in $data_file"
                    echo "Please record the profile again."
                    exit 1
                else
                    if [ -d "$output_directory"]; then
                        read -p "$output_directory directory already exists, continue? (y/n)" answer
                        if [ $answer = "n" ]; then
                            exit 1
                        fi
                    else 
                        mkdir -p "$output_directory"
                    fi
                    base_name="${data_file%.data}"
                    perf2bolt "$CPATH/clang-16" -p "$data_file" -o "$output_directory/${base_name}.fdata" -w "$output_directory/${base_name}.yaml"
                fi
            done
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

