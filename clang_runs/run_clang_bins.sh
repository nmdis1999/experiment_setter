#!/bin/bash

set -e

check_for () {
    which $1 > /dev/null 2> /dev/null
    if [ $? -ne 0 ]; then
        echo "Error: can't find $1 binary"
        missing=1
    fi
}

# List of all clang binaries
clang_bins=(
    "clang.all-prog-aggr-lbr"
    "clang.exts.pt"
    "clang.tty.pt"
    "clang.format.pt"
    "clang.window-copy.pt"
)

# Loop over clang binaries
for cbin in "${clang_bins[@]}"; do
    CC="$HOME/research/clang-16/benchmark/install/bin/$cbin"
    if check_for $CC; then
        echo -e "\033[33;44mRunning with binary: $cbin\033[0m"
        ./multi_run.sh $CC
    else
        echo -e "\033[33;44mBinary doesn't exist: $cbin\033[0m"
    fi 
done
