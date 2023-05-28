#!/bin/bash

set -e

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
CC_DIR="$(dirname "$CC")"

# Function to create a directory if it does not exist
create_dir_if_not_exists() {
  local dir_name=$1

  if [ ! -d "$dir_name" ]; then
    mkdir "${EXP_DIR}/${dir_name}"
    echo "Created directory '$dir_name'"
  else
    echo "Directory '$dir_name' already exists"
    exit 1
  fi
}

# Loop over all arguments
while (( "$#" )); do
  case "$1" in
    -nl)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        echo "Option 'nl' has value '$2'"
        if [ -n "$3" ] && [ ${3:0:1} != "-" ]; then
            dest_dir="${3}${2}_nl"
            create_dir_if_not_exists "$dest_dir"
            for ((i=0; i<$2; i++))
            do
                perf record -o "nl-$i.data" -- $HOME/report/experiment_setter/tmux/multi_perf.sh
                $BOLT_PATH/perf2bolt $CC --nl -p "nl-$i.data" -o "${EXP_DIR}/${dest_dir}/nl-$i.fdata"
                rm -rf "nl-$i.data"
            done
            current_dir="$(pwd)"
            cd "${EXP_DIR}/${dest_dir}"
            merge-fdata -o nl-aggregated.fdata nl-*.fdata
            llvm-bolt $CC -o $CC_DIR/clang.${3}.${2}.nl -b nl-aggregated.fdata \
             -reorder-blocks=ext-tsp -reorder-functions=hfsort+ -split-functions \
             -split-all-cold -dyno-stats -icf=1 -use-gnu-stack
            cd $current_dir 
            # todo: add pt mode profile collection and clang build.
        fi
        shift 3
      else
        echo "Error: Argument for 'nl' is missing" >&2
        exit 1
      fi
      ;;
    -lbr)
       if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        if [ -n "$3" ] && [ ${3:0:1} != "-" ]; then
            dest_dir="${3}${2}_lbr"
            create_dir_if_not_exists "$dest_dir"
            for ((i=0; i<$2; i++))
            do
                perf record -o "${EXP_DIR}/${dest_dir}/lbr-$i.data" -e cycles:u -j any,u -- $HOME/report/experiment_setter/tmux/multi_perf.sh
                $BOLT_PATH/perf2bolt $CC -p "${EXP_DIR}/${dest_dir}/lbr-$i.data" -o "${EXP_DIR}/${dest_dir}/lbr-$i.fdata"
                rm -rf "${EXP_DIR}/${dest_dir}/lbr-$i.data"
            done
            if [ ! which ${CC_DIR}/clang.${3}.pt > /dev/null 2> /dev/null ]; then
                while true
                do
                    rm -rf pt.data
                    perf record -o "${EXP_DIR}/${dest_dir}/pt.data" -e intel_pt//u -m,256M -- $HOME/report/experiment_setter/tmux/multi_perf.sh
                    if perf script -i ${EXP_DIR}/${dest_dir}/pt.data --itrace=e | grep -q "instruction trace error"; then 
                        echo "Instruction trace error, recording data again ..." 
                    else
                        echo "Captured  pt.data without Instruction trace errors." 
                        break
                    fi 
                done
                echo -e "\033[33;44mPT data captured.\033[0m"
                $BOLT_PATH/perf2bolt $CC -p "${EXP_DIR}/${dest_dir}/pt.data" -o "${EXP_DIR}/${dest_dir}/pt.fdata"
                llvm-bolt $CC -o $CC_DIR/clang.${3}.pt -b "${EXP_DIR}/${dest_dir}/pt.fdata" \
                    -reorder-blocks=ext-tsp -reorder-functions=hfsort+ -split-functions \
                    -split-all-cold -dyno-stats -icf=1 -use-gnu-stack
                rm -rf pt.data
            else
                echo -e "\033[33;44mPT profiled clang exists.\033[0m"
            fi
            current_dir="$(pwd)"       
            cd "${EXP_DIR}/${dest_dir}"
            merge-fdata -o lbr-aggregated.fdata lbr-*.fdata 
            llvm-bolt $CC -o $CC_DIR/clang.${3}.${2}.lbr -b lbr-aggregated.fdata \
                -reorder-blocks=ext-tsp -reorder-functions=hfsort+ -split-functions \
                -split-all-cold -dyno-stats -icf=1 -use-gnu-stack
            cd $current_dir
        fi
        shift 3
      else
        echo "Error: Argument for 'nl' is missing" >&2
        exit 1
      fi
      ;;  
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

