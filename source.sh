#!/bin/bash
# python3 
export PATH=/home/develop/install/Python-3.13.0/bin/:$PATH

# binutils
export PATH=/home/develop/install/binutils-2.43.1/bin/:$PATH

# gcc/g++ 14.2
export PATH=/home/develop/install/gcc-14.2.0/bin/:$PATH
export LD_LIBRARY_PATH=/home/develop/install/gcc-14.2.0/lib64/:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=/home/develop/install/gcc-14.2.0/include/c++/14.2.0/:/home/develop/install/gcc-14.2.0/include/c++/14.2.0/x86_64-pc-linux-gnu/:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=/home/develop/install/gcc-14.2.0/include/c++/14.2.0/:/home/develop/install/gcc-14.2.0/include/c++/14.2.0/x86_64-pc-linux-gnu/:$CPLUS_INCLUDE_PATH

# llvm/clang/clang++
export PATH=/home/develop/install/LLVM-19.1.3/bin/:$PATH
export LD_LIBRARY_PATH=/home/develop/install/LLVM-19.1.3/lib/:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=/home/develop/install/LLVM-19.1.3/include/:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=/home/develop/install/LLVM-19.1.3/include/:$CPLUS_INCLUDE_PATH

# gn
export PATH=/home/develop/src/gn/out/:$PATH
