#!/bin/bash
set -e

read -p "Current working directory is $(pwd). Want to change it? (y/n)" answer

if [ "$answer" = "y" ]; then
        exit
fi

if [ -d "tmux" ]; then
    read -p "The 'tmux' directory already exists. Do you want to continue? (y/n) " answer
    if [ "$answer" = "n" ]; then
        echo "Directory tmux already exists, exiting script."
        exit 1
    fi
else
    git clone https://github.com/tmux/tmux.git

    # Run autogen.sh and configure
    cd tmux
    sh autogen.sh
    ./configure
fi

if [ $# -eq 0 ]; then
    echo "Please provide the path to clang binary as an argument (e.g /usr/local/bin)"
    exit 1
fi

CPATH=$1

$CPATH/clang --version > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Clang binary found at $CPATH"
else
    echo "No executable clang binary found at $CPATH"
fi

cd tmux

# Set the CFLAGS and DFLAGS variables
CFLAGS="-std=gnu99 -O2 -g -Wno-long-long -Wall -W -Wformat=2
-Wmissing-prototypes -Wstrict-prototypes -Wmissing-declarations -Wwrite-strings
-Wshadow -Wpointer-arith -Wsign-compare -Wundef -Wbad-function-cast -Winline
-Wcast-align -Wdeclaration-after-statement -Wno-pointer-sign -Wno-attributes
-Wno-unused-result -Wno-format-y2k" 

DFLAGS="-DPACKAGE_NAME=\"tmux\"
-DPACKAGE_TARNAME=\"tmux\" -DPACKAGE_VERSION=\"next-3.4\"
-DPACKAGE_STRING=\"tmux next-3.4\" -DPACKAGE_BUGREPORT=\"\" -DPACKAGE_URL=\"\"
-DPACKAGE=\"tmux\" -DVERSION=\"next-3.4\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1
-DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1
-DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1
-D__EXTENSIONS__=1 -D_ALL_SOURCE=1 -D_GNU_SOURCE=1 -D_POSIX_PTHREAD_SEMANTICS=1
-D_TANDEM_SOURCE=1 -DHAVE_DIRENT_H=1 -DHAVE_FCNTL_H=1 -DHAVE_INTTYPES_H=1
-DHAVE_PATHS_H=1 -DHAVE_PTY_H=1 -DHAVE_STDINT_H=1 -DHAVE_SYS_DIR_H=1
-DHAVE_LIBM=1 -DHAVE_DIRFD=1 -DHAVE_FLOCK=1 -DHAVE_PRCTL=1 -DHAVE_SYSCONF=1
-DHAVE_ASPRINTF=1 -DHAVE_CFMAKERAW=1 -DHAVE_CLOCK_GETTIME=1
-DHAVE_EXPLICIT_BZERO=1 -DHAVE_GETDTABLESIZE=1 -DHAVE_GETLINE=1 -DHAVE_MEMMEM=1
-DHAVE_SETENV=1 -DHAVE_STRCASESTR=1 -DHAVE_STRNDUP=1 -DHAVE_STRSEP=1
-DHAVE_EVENT2_EVENT_H=1 -DHAVE_NCURSES_H=1 -DHAVE_B64_NTOP=1
-DHAVE_MALLOC_TRIM=1 -DHAVE_DAEMON=1 -DHAVE_FORKPTY=1 -DHAVE___PROGNAME=1
-DHAVE_PROGRAM_INVOCATION_SHORT_NAME=1 -DHAVE_PR_SET_NAME=1
-DHAVE_SO_PEERCRED=1 -DHAVE_PROC_PID=1 -I. -D_DEFAULT_SOURCE
-D_XOPEN_SOURCE=600 -DTMUX_VERSION=\"next-3.4\"
-DTMUX_CONF=\"/etc/tmux.conf:~/.tmux.conf:$XDG_CONFIG_HOME/tmux/tmux.conf:~/.config/tmux/tmux.conf\"
-DTMUX_TERM=\"tmux-256color\" -DDEBUG -iquote."

# NO LBR Mode (Not wrapping 80 words per line for perd because command doesn't run properly) 
perf record -o nolbr.data -- env CFLAGS="$CFLAGS" DFLAGS="$DFLAGS" $CPATH/clang-16 -MT window-copy.o -MD -MP -MF $depbase.Tpo -c -o window-copy.o window-copy.c

# LBR Mode
perf record -o lbr.data -e cycles:u -j any,u -- env CFLAGS="$CFLAGS"
DFLAGS="$DFLAGS" $CPATH/clang-16 -MT window-copy.o -MD -MP -MF $depbase.Tpo -c
-o window-copy.o window-copy.c

# Intel PT Mode first try to capture data, we will be making sure we don't get
# trace error.
# https://perf.wiki.kernel.org/index.php/Latest_Manual_Page_of_perf-intel-pt.1#:~:text=be%20used%20together.-,Buffer%20handling,-There%20may%20be

while true; do
    rm -rf pt.data
    perf record -o pt.data -e intel_pt//u -m,256M -- env CFLAGS="$CFLAGS" DFLAGS="$DFLAGS" $CPATH/clang-16 -MT window-copy.o -MD -MP -MF $depbase.Tpo -c -o window-copy.o window-copy.c 
   if perf script -i pt.data --itrace=e | grep -q "instruction trace error"; then 
        echo "Instruction trace error, recording data again ..." 
    else 
        echo "Captured pt.data without Instruction trace errors." 
        break 
    fi 

perf2bolt $CPATH/clang-16 --nl -p nolbr.data -o nolbr.fdata -w nolbr.yaml
perf2bolt $CPATH/clang-16 -p lbr.data -o lbr.fdata -w lbr.yaml
perf2bolt $CPATH/clang-16 -p pt.data -o pt.fdata -w pt.yaml

llvm-bolt $CPATH/clang-16 -o $CPATH/clang-16.tmp1 -b nolbr.yaml \
    -reorder-blocks=ext-tsp -reorder-functions=hfsort+ -split-functions \
    -split-all-cold -dyno-stats -icf=1 -use-gnu-stack

llvm-bolt $CPATH/clang-16 -o $CPATH/clang.tmp2 -b lbr.yaml \
    -reorder-blocks=ext-tsp -reorder-functions=hfsort+ -split-functions \
    -split-all-cold -dyno-stats -icf=1 -use-gnu-stack

llvm-bolt $CPATH/clang-16 -o $CPATH/clang.tmp3 -b pt.yaml \
    -reorder-blocks=ext-tsp -reorder-functions=hfsort+ -split-functions \
    -split-all-cold -dyno-stats -icf=1 -use-gnu-stack

multitime -n 100 -r "rm -rf window-copy.o" -s 0 $CPATH/clang-16.tmp
    -DPACKAGE_NAME=\"tmux\" -DPACKAGE_TARNAME=\"tmux\"
    -DPACKAGE_VERSION=\"next-3.4\" -DPACKAGE_STRING=\"tmux\ next-3.4\"
    -DPACKAGE_BUGREPORT=\"\" -DPACKAGE_URL=\"\" -DPACKAGE=\"tmux\"
    -DVERSION=\"next-3.4\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1
    -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1
    -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1
    -D__EXTENSIONS__=1 -D_ALL_SOURCE=1 -D_GNU_SOURCE=1 -D_POSIX_PTHREAD_SEMANTICS=1
    -D_TANDEM_SOURCE=1 -DHAVE_DIRENT_H=1 -DHAVE_FCNTL_H=1 -DHAVE_INTTYPES_H=1
    -DHAVE_PATHS_H=1 -DHAVE_PTY_H=1 -DHAVE_STDINT_H=1 -DHAVE_SYS_DIR_H=1
    -DHAVE_LIBM=1 -DHAVE_DIRFD=1 -DHAVE_FLOCK=1 -DHAVE_PRCTL=1 -DHAVE_SYSCONF=1
    -DHAVE_ASPRINTF=1 -DHAVE_CFMAKERAW=1 -DHAVE_CLOCK_GETTIME=1
    -DHAVE_EXPLICIT_BZERO=1 -DHAVE_GETDTABLESIZE=1 -DHAVE_GETLINE=1 -DHAVE_MEMMEM=1
    -DHAVE_SETENV=1 -DHAVE_STRCASESTR=1 -DHAVE_STRNDUP=1 -DHAVE_STRSEP=1
    -DHAVE_EVENT2_EVENT_H=1 -DHAVE_NCURSES_H=1 -DHAVE_B64_NTOP=1
    -DHAVE_MALLOC_TRIM=1 -DHAVE_DAEMON=1 -DHAVE_FORKPTY=1 -DHAVE___PROGNAME=1
    -DHAVE_PROGRAM_INVOCATION_SHORT_NAME=1 -DHAVE_PR_SET_NAME=1
    -DHAVE_SO_PEERCRED=1 -DHAVE_PROC_PID=1 -I.  -D_DEFAULT_SOURCE
    -D_XOPEN_SOURCE=600 -DTMUX_VERSION='"next-3.4"'
    -DTMUX_CONF='"/etc/tmux.conf:~/.tmux.conf:$XDG_CONFIG_HOME/tmux/tmux.conf:~/.config/tmux/tmux.conf"'
    -DTMUX_TERM='"tmux-256color"' -DDEBUG -iquote.  -std=gnu99 -O2 -g
    -Wno-long-long -Wall -W -Wformat=2 -Wmissing-prototypes -Wstrict-prototypes
    -Wmissing-declarations -Wwrite-strings -Wshadow -Wpointer-arith -Wsign-compare
    -Wundef -Wbad-function-cast -Winline -Wcast-align -Wdeclaration-after-statement
    -Wno-pointer-sign -Wno-attributes -Wno-unused-result -Wno-format-y2k -MT
    window-copy.o -MD -MP -MF $depbase.Tpo -c -o window-copy.o window-copy.c

