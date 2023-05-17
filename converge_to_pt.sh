#!/bin/bash

echo "Using CC=$CC"
echo "Clean pre-build files."
rm -rf window-copy.o
rm -rf tty.o
rm -rf gcc.o
rm -rf format.o
rm -rf "$HOME/research/extsmail/extsmaild.o"

echo "Cleaned pre-build files."

missing=0
check_for () {
    which $1 > /dev/null 2> /dev/null
    if [ $? -ne 0 ]; then
        echo "Error: can't find $1 binary"
        missing=1
    fi
}

check_for perf
check_for merge-fdata
check_for $CC

BOLT_PATH="$HOME/ptperf/build/bin"
EXP_DIR="$HOME/report/experiment_setter"

# if [[ ! -d "$HOME/report/experiment_setter/lbr_data" ]]; then
#     mkdir -p "$HOME/report/experiment_setter/lbr_data"
# else 
#     echo "directory already exist, exiting."
#     exit 1
# fi

# for ((i=1; i<2; i++))
# do
#     perf record -o pt-$i.data -e intel_pt//u -m,256M $HOME/report/experiment_setter/tmux/multi_perf.sh
#     $BOLT_PATH/perf2bolt $CC -p pt-$i.data -o $HOME/report/experiment_setter/pt_data/pt-$i.fdata
# done

if [[ ! -d "${EXP_DIR}/lbr_data" ]]; then
    mkdir -p "${EXP_DIR}/lbr_data"
else 
    echo "directory already exist, exiting."
    exit 1
fi

for ((i=0; i <5; i++))
do
    perf record -o lbr-$i.data -e cycles:u -j any,u -- $HOME/report/experiment_setter/tmux/multi_perf.sh
    $BOLT_PATH/perf2bolt $CC -p lbr-$i.data -o ${EXP_DIR}/lbr_data/lbr-$i.fdata
done

rm -rf lbr-*

current_dir="$(pwd)"
cd ${EXP_DIR}/lbr_data
merge-fdata -o lbr-aggregated.fdata lbr-*.fdata
cd $current_dir

