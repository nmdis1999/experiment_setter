#!/bin/bash

set -e

cd $HOME/research/

perf record clang gcc.c
