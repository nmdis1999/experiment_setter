#! /bin/sh

set -e

home=$HOME/report
dirc=$1

missing=0
check_for () {
    which $1 > /dev/null 2> /dev/null
    if [ $? -ne 0 ]; then
        echo "Error: can't find $1 binary"
        missing=1
    fi
}

if [ -z "$dirc" ]; then
    dirc="bolt"
fi

TOPLEV=$home/$dirc

if [ ! -d $TOPLEV ]; then
    mkdir $TOPLEV
fi

cd $TOPLEV

# Check if llvm-project repo exists, otherwise clone it
if [ -d "llvm-project" ]; then
    cd llvm-project
    git pull
    cd ..
else
    git clone https://github.com/nmdis1999/llvm-project.git
fi

if [ -d "build" ]; then
    read -p "The 'build' directory already exists. Do you want to continue? (y/n) " answer
    if [ "$answer" != "y" ]; then
        echo "Exiting script."
        exit 1
    fi
else
    # Create a build directory and navigate to it
    mkdir build
    # Run cmake and ninja to build bolt
    cmake -G Ninja ../llvm-project/llvm \
    -DLLVM_TARGETS_TO_BUILD="X86;AArch64" -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_ENABLE_PROJECTS="bolt"
    ninja bolt install
fi

# Exporting path to llvm-bolt and perf2bolt binaries
export PATH=$TOPLEV/build/bin:$PATH

# Bootstrapping Clang v x.x.x with PGO and LTO

echo "Enter name for stage1 clang build (default: stage1)"
read stage1_dir

if [ -z "$stage1_dir" ]; then
    stage1_dir="stage1"
fi

# Build stage1 clang from default gcc

if [ -d "${TOPLEV}/$stage1_dir" ]; then
    read -p "The '${stage1_dir}' directory already exists. Do you want to continue? (y/n) " answer
    if [ "$answer" != "y" ]; then
        echo "Directory ${stage1_dir} already exists, exiting script."
        exit 1
    fi
else
    # Build stage1 clang from default gcc
    mkdir "${TOPLEV}/$stage1_dir"
    cd "${TOPLEV}/$stage1_dir"
    cmake -G Ninja ${TOPLEV}/llvm-project/llvm -DLLVM_TARGETS_TO_BUILD=X86 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_ASM_COMPILER=gcc \
    -DLLVM_ENABLE_PROJECTS="clang;lld" \
    -DLLVM_ENABLE_RUNTIMES="compiler-rt" \
    -DCOMPILER_RT_BUILD_SANITIZERS=OFF -DCOMPILER_RT_BUILD_XRAY=OFF \
    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
    -DCMAKE_INSTALL_PREFIX=${TOPLEV}/$stage1_dir/install
    ninja install
fi

# Build stage2 clang with instrumentation
cd $path

echo "Enter name for stage2 profile generation build (default: stage2-prof-gen)"
read stage2_dir

if [ -z "$stage2_dir" ]; then 
    stage2_dir="stage2-prof-gen"
fi

if [ -d "${TOPLEV}/$stage2_dir" ]; then
    read -p "The '${stage2_dir}' directory already exists. Do you want to continue? (y/n) " answer
    if [ "$answer" != "y" ]; then
        echo "Directory ${stage2_dir} already exists, exiting script."
        exit 1
    fi
else
    mkdir "${TOPLEV}/$stage2_dir"
    cd "${TOPLEV}/$stage2_dir"

    CPATH=${TOPLEV}/$stage1_dir/install/bin/    
    cmake -G Ninja ${TOPLEV}/llvm-project/llvm -DLLVM_TARGETS_TO_BUILD=X86 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=$CPATH/clang -DCMAKE_CXX_COMPILER=$CPATH/clang++ \
    -DLLVM_ENABLE_PROJECTS="clang;lld" \
    -DLLVM_USE_LINKER=lld -DLLVM_BUILD_INSTRUMENTED=ON \
    -DCMAKE_INSTALL_PREFIX=${TOPLEV}/$stage2_dir/install

    ninja install

fi

# Generating profile for PGO
echo "Enter name for stage3 profile generation build (default: stage3-train)"
read stage3_train

if [ -z "$stage3_train" ]; then 
    stage3_train="stage3-train"
fi

if [ -d "${TOPLEV}/$stage3_train" ]; then
    read -p "The '${stage3_train}' directory already exists. Do you want to continue? (y/n) " answer
    if [ "$answer" != "y" ]; then
        echo "Directory ${stage3_train} already exists, exiting script."
        exit 1
    fi
else
    mkdir "${TOPLEV}/$stage3_train"
    cd "${TOPLEV}/$stage3_train"

    CPATH=${TOPLEV}/$stage2_dir/install/bin    
    cmake -G Ninja ${TOPLEV}/llvm-project/llvm -DLLVM_TARGETS_TO_BUILD=X86 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=$CPATH/clang -DCMAKE_CXX_COMPILER=$CPATH/clang++ \
    -DLLVM_ENABLE_PROJECTS="clang;lld" \
    -DLLVM_USE_LINKER=lld -DLLVM_BUILD_INSTRUMENTED=ON \
    -DCMAKE_INSTALL_PREFIX=${TOPLEV}/$stage3_train/install

    ninja clang   
fi

cd ${TOPLEV}/stage2-prof-gen/profiles
${TOPLEV}/stage1/install/bin/llvm-profdata merge -output=clang.profdata *

# Building clang with PGO and LTO
echo "Enter name for stage4 profile generation build (default: stage2-prof-use-lto)"
read stage4

if [ -z "$stage4" ]; then 
    stage4="stage4"
fi

if [ -d "${TOPLEV}/$stage4" ]; then
    read -p "The '${stage4}' directory already exists. Do you want to continue? (y/n) " answer
    if [ "$answer" != "y" ]; then
        echo "Directory ${stage4} already exists, exiting script."
        exit 1
    fi
else
    mkdir "${TOPLEV}/$stage4"
    cd "${TOPLEV}/$stage4"

    CPATH=${TOPLEV}/$stage1_dir/install/bin/
    export LDFLAGS="-Wl,-q"
    cmake -G Ninja ${TOPLEV}/llvm-project/llvm -DLLVM_TARGETS_TO_BUILD=X86 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=$CPATH/clang -DCMAKE_CXX_COMPILER=$CPATH/clang++ \
    -DLLVM_ENABLE_PROJECTS="clang;lld" \
    -DLLVM_ENABLE_LTO=Full \
    -DLLVM_PROFDATA_FILE=${TOPLEV}/$stage3_train/profiles/clang.profdata \
    -DLLVM_USE_LINKER=lld \
    -DCMAKE_INSTALL_PREFIX=${TOPLEV}/$stage4/install
    ninja install
fi

