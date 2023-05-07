#!/bin/bash

# This script runs multitime(https://tratt.net/laurie/src/multitime/) on
# different three C programs.

missing=0
check_for () {
    which $1 > /dev/null 2> /dev/null
    if [ $? -ne 0 ]; then
        echo "Error: can't find $1 binary"
        missing=1
    fi
}

check_for multitime

compile_tty() {
    # Path to clang binary
    local CPATH="$1"
    multitime -n 3 -s 0 -r "rm -rf tty.o" $CPATH -DPACKAGE_NAME=\"tmux\" \
    -DPACKAGE_TARNAME=\"tmux\" \
    -DPACKAGE_VERSION=\"next-3.4\" \
    -DPACKAGE_STRING=\"tmux\ next-3.4\" \
    -DPACKAGE_BUGREPORT=\"\" \
    -DPACKAGE_URL=\"\" \
    -DPACKAGE=\"tmux\" \
    -DVERSION=\"next-3.4\" \
    -DSTDC_HEADERS=1 \
    -DHAVE_SYS_TYPES_H=1 \
    -DHAVE_SYS_STAT_H=1 \
    -DHAVE_STDLIB_H=1 \
    -DHAVE_STRING_H=1 \
    -DHAVE_MEMORY_H=1 \
    -DHAVE_STRINGS_H=1 \
    -DHAVE_INTTYPES_H=1 \
    -DHAVE_STDINT_H=1 \
    -DHAVE_UNISTD_H=1 \
    -D__EXTENSIONS__=1 \
    -D_ALL_SOURCE=1 \
    -D_GNU_SOURCE=1 \
    -D_POSIX_PTHREAD_SEMANTICS=1 \
    -D_TANDEM_SOURCE=1 \
    -DHAVE_DIRENT_H=1 \
    -DHAVE_FCNTL_H=1 \
    -DHAVE_INTTYPES_H=1 \
    -DHAVE_PATHS_H=1 
    -DHAVE_PTY_H=1 \
    -DHAVE_STDINT_H=1 \
    -DHAVE_SYS_DIR_H=1 \
    -DHAVE_LIBM=1 \
    -DHAVE_DIRFD=1 \
    -DHAVE_FLOCK=1 \
    -DHAVE_PRCTL=1 \
    -DHAVE_SYSCONF=1 \
    -DHAVE_ASPRINTF=1 \
    -DHAVE_CFMAKERAW=1 \
    -DHAVE_CLOCK_GETTIME=1 \
    -DHAVE_EXPLICIT_BZERO=1 \
    -DHAVE_GETDTABLESIZE=1 \
    -DHAVE_GETLINE=1 \
    -DHAVE_MEMMEM=1 \
    -DHAVE_SETENV=1 \
    -DHAVE_STRCASESTR=1 \
    -DHAVE_STRNDUP=1 \
    -DHAVE_STRSEP=1 \
    -DHAVE_EVENT2_EVENT_H=1 \
    -DHAVE_NCURSES_H=1 \
    -DHAVE_TIPARM=1 \
    -DHAVE_B64_NTOP=1 \
    -DHAVE_MALLOC_TRIM=1 \
    -DHAVE_DAEMON=1 \
    -DHAVE_FORKPTY=1 \
    -DHAVE___PROGNAME=1 \
    -DHAVE_PROGRAM_INVOCATION_SHORT_NAME=1 \
    -DHAVE_PR_SET_NAME=1 \
    -DHAVE_SO_PEERCRED=1 \
    -DHAVE_PROC_PID=1 \
    -I. \
    -D_DEFAULT_SOURCE \
    -D_XOPEN_SOURCE=600 \
    -DTMUX_VERSION='"next-3.4"' \
    -DTMUX_CONF='"/etc/tmux.conf:~/.tmux.conf:$XDG_CONFIG_HOME/tmux/tmux.conf:~/.config/tmux/tmux.conf"' \
    -DTMUX_LOCK_CMD='"lock -np"' \
    -DTMUX_TERM='"tmux-256color"' \
    -DDEBUG \
    -iquote. \
    -std=gnu99 \
    -O2 \
    -g \
    -Wno-long-long \
    -Wall \
    -W \
    -Wformat=2 \
    -Wmissing-prototypes \
    -Wstrict-prototypes \
    -Wmissing-declarations \
    -Wwrite-strings \
    -Wshadow \
    -Wpointer-arith \
    -Wsign-compare \
    -Wundef \
    -Wbad-function-cast \
    -Winline \
    -Wcast-align \
    -Wdeclaration-after-statement \
    -Wno-pointer-sign \
    -Wno-attributes \
    -Wno-unused-result \
    -Wno-format-y2k \
    -MT tty.o \
    -MD \
    -MP \
    -MF $depbase.Tpo \
    -c \
    -o tty.o tty.c
}

compile_format() {    
    local CPATH="$1"
    multitime -n 3 -s 0 -r "rm -rf format.o" $CPATH -DPACKAGE_NAME=\"tmux\" \
    -DPACKAGE_TARNAME=\"tmux\" \
    -DPACKAGE_VERSION=\"next-3.4\" \
    -DPACKAGE_STRING=\"tmux\ next-3.4\" \
    -DPACKAGE_BUGREPORT=\"\" \
    -DPACKAGE_URL=\"\" \
    -DPACKAGE=\"tmux\" \
    -DVERSION=\"next-3.4\" \
    -DSTDC_HEADERS=1 \
    -DHAVE_SYS_TYPES_H=1 \
    -DHAVE_SYS_STAT_H=1 \
    -DHAVE_STDLIB_H=1 \
    -DHAVE_STRING_H=1 \
    -DHAVE_MEMORY_H=1 \
    -DHAVE_STRINGS_H=1 \
    -DHAVE_INTTYPES_H=1 \
    -DHAVE_STDINT_H=1 \
    -DHAVE_UNISTD_H=1 \
    -D__EXTENSIONS__=1 \
    -D_ALL_SOURCE=1 \
    -D_GNU_SOURCE=1 \
    -D_POSIX_PTHREAD_SEMANTICS=1 \
    -D_TANDEM_SOURCE=1 \
    -DHAVE_DIRENT_H=1 \
    -DHAVE_FCNTL_H=1 \
    -DHAVE_INTTYPES_H=1 \
    -DHAVE_PATHS_H=1 \
    -DHAVE_PTY_H=1 \
    -DHAVE_STDINT_H=1 \
    -DHAVE_SYS_DIR_H=1 \
    -DHAVE_LIBM=1 \
    -DHAVE_DIRFD=1 \
    -DHAVE_FLOCK=1 \
    -DHAVE_PRCTL=1 \
    -DHAVE_SYSCONF=1 \
    -DHAVE_ASPRINTF=1 \
    -DHAVE_CFMAKERAW=1 \
    -DHAVE_CLOCK_GETTIME=1 \
    -DHAVE_EXPLICIT_BZERO=1 \
    -DHAVE_GETDTABLESIZE=1 \
    -DHAVE_GETLINE=1 \
    -DHAVE_MEMMEM=1 \
    -DHAVE_SETENV=1 \
    -DHAVE_STRCASESTR=1 \
    -DHAVE_STRNDUP=1 \
    -DHAVE_STRSEP=1 \
    -DHAVE_EVENT2_EVENT_H=1 \
    -DHAVE_NCURSES_H=1 \
    -DHAVE_TIPARM=1 \
    -DHAVE_B64_NTOP=1 \
    -DHAVE_MALLOC_TRIM=1 \
    -DHAVE_DAEMON=1 \
    -DHAVE_FORKPTY=1 \
    -DHAVE___PROGNAME=1 \
    -DHAVE_PROGRAM_INVOCATION_SHORT_NAME=1 \
    -DHAVE_PR_SET_NAME=1 \
    -DHAVE_SO_PEERCRED=1 \
    -DHAVE_PROC_PID=1 \
    -I. \
    -D_DEFAULT_SOURCE \
    -D_XOPEN_SOURCE=600 \
    -DTMUX_VERSION='"next-3.4"' \
    -DTMUX_CONF='"/etc/tmux.conf:~/.tmux.conf:$XDG_CONFIG_HOME/tmux/tmux.conf:~/.config/tmux/tmux.conf"' \
    -DTMUX_LOCK_CMD='"lock -np"' \
    -DTMUX_TERM='"tmux-256color"' \
    -DDEBUG \
    -iquote. \
    -std=gnu99 \
    -O2 \
    -g \
    -Wno-long-long \
    -Wall \
    -W \
    -Wformat=2 \
    -Wmissing-prototypes \
    -Wstrict-prototypes \
    -Wmissing-declarations \
    -Wwrite-strings \
    -Wshadow \
    -Wpointer-arith \
    -Wsign-compare \
    -Wundef \
    -Wbad-function-cast \
    -Winline \
    -Wcast-align \
    -Wdeclaration-after-statement \
    -Wno-pointer-sign \
    -Wno-attributes \
    -Wno-unused-result \
    -Wno-format-y2k \
    -MT format.o \
    -MD \
    -MP \
    -MF $depbase.Tpo \
    -c \
    -o format.o format.c
}

compile_gcc() {
    local CPATH="$1"
    multitime -n 3 -s 0 -r "rm -rf gcc.o" $CPATH -o gcc.o gcc.c
}

run_with() {
    local BINPATH ="$1"
    compile_format $BINPATH
    compile_tty $BINPATH
    compile_gcc $BINPATH
}

BINPATH=/usr/bin/clang
check_for $BINPATH
run_with $BINPATH
