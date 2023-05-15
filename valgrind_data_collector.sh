#!/bin/bash

# Directory containing clang binaries
CLANG_DIR="$HOME/research/clang-16/stage2-prof-use-lto/install/bin"

val_run_script="$HOME/report/experiment_setter/tmux/val_run.sh"

missing=0
check_for () {
    which $1 > /dev/null 2> /dev/null
    if [ $? -ne 0 ]; then
        echo "Error: can't find $1 binary"
        missing=1
    fi
}

check_for find
check_for xargs
check_for basename
if [ $missing -ne 0 ]; then
    exit 1
fi

# Counter for clang versions
counter=0

# Regular expression for matching desired clang binaries
regex="clang-[16]+(\.[a-zA-Z]+)*(\.exts|\.window-copy|\.tty|\.format)$"

# regex="clang-16\.pt(\.[a-zA-Z]+)*(\.exts|\.window-copy|\.tty|\.format)$"
#
# Iterate over clang binaries
for clang_bin in ${CLANG_DIR}/clang-*; do
    # Check if the binary exists, is executable, and matches the regex
    if [[ -x "$clang_bin" && "$clang_bin" =~ $regex ]]; then
        # Increment the counter
        ((counter++))

        # Print version of the clang binary
        echo "Processing $clang_bin:"
        CC=$clang_bin bash $val_run_script
        
    fi
done

# Print total number of clang versions found
echo "Total clang versions found: $counter"

