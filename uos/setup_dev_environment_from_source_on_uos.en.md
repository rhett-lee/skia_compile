English | [简体中文](setup_dev_environment_from_source_on_uos.md)

Last synced: 2026-09-28

# Manually Compiling and Installing the Development Environment from Source on UOS
 - Last updated: 2025-05-25
 - Operating system: UOS Desktop Professional AMD64 (1070 HWE edition)

## 1. Preparation: Install Required Software
1. After installing the system, you can upgrade it to the latest:
   (1) Upgrade the system: `sudo apt update`
   (2) Upgrade the system: `sudo apt upgrade -y`
2. Install the required software
```
sudo apt install -y gcc g++ gdb make git cmake python3 ninja-build wget unzip
```
The installed software versions are as follows:
```
cmake is already the newest version (3.22.1.1-1).
g++ is already the newest version (4:8.3.0-1+sign).
gcc is already the newest version (4:8.3.0-1+sign).
gdb is already the newest version (8.2.1.1-1+security).
git is already the newest version (1:2.20.1.3-2+dde).
make is already the newest version (4.2.1.1-1+dde).
ninja-build is already the newest version (1.8.2-1).
python3 is already the newest version (3.7.3.1-deepin1).
unzip is already the newest version (6.0.7.2-1+deepin+sign).
wget is already the newest version (1.20.1.6-deepin1).
```
Note: the development tool versions provided by the system by default are too old. When they cannot meet requirements, you must build the latest versions of the development tools from source, including binutils, python3, gcc/g++, llvm/clang/clang++, gn, and so on.

# 2. Manually Compile and Install the Development Environment from Source
Minimum memory requirement: 16 GB; the build fails if memory is insufficient.
Disk space requirement: around 35 GB.

1. Compile and install the latest binutils (the system-bundled version is too old; linking gcc/g++/llvm/clang/clang++ with ld/gold causes errors)
```
#!/bin/bash
cd ~/develop; mkdir src                                  # create source directory
cd ~/develop/src                                         # set working directory
wget https://ftp.gnu.org/gnu/binutils/binutils-2.43.1.tar.gz # download source code
tar -xzf binutils-2.43.1.tar.gz                              # extract source code
cd binutils-2.43.1                                           # enter source directory
./configure --prefix=~/develop/install/binutils-2.43.1/ --disable-werror --enable-gprofng=no # run configure script
  # Note: the --enable-gprofng=no option is used because gprofng's source has a compilation error.    
make                                                         # build
make install                                                 # install

```
2. Compile and install a newer python3 (3.13.0) from source, because the system-bundled version (3.7.3) is too old to compile llvm and must be upgraded
```
#!/bin/bash
cd ~/develop/src                                                # set working directory
wget https://www.python.org/ftp/python/3.13.0/Python-3.13.0.tar.xz  # download source code
tar -xJf Python-3.13.0.tar.xz                                       # extract source code
cd Python-3.13.0                                                    # enter source directory
./configure --prefix=~/develop/install/Python-3.13.0/           # run configure script
make                                                                # build
make install                                                        # install (errors may occur but are harmless)
```
3. Compile and install a newer gcc/g++ (14.2.0) from source, because the system-bundled version is too old and must be upgraded
```
#!/bin/bash
# Build requirements: 4GB RAM, 12GB disk space

cd ~/develop/src                                            # set working directory
wget https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.gz   # download source code
tar -xzf gcc-14.2.0.tar.gz                                      # extract source code
cd ~/develop/src/gcc-14.2.0                                 # enter gcc-14.2.0 source directory
./contrib/download_prerequisites                                # download third-party libraries required for building

# Configuration (note: because the ld shipped with UOS (v2.31.1) fails to link gcc/g++, we use the latest ld (v2.43.1) built from source)
mkdir -p ~/develop/src/gcc-14.2.0.build
cd ~/develop/src/gcc-14.2.0.build
export LD="~/develop/install/binutils-2.43.1/bin/ld"
../gcc-14.2.0/configure --prefix=~/develop/install/gcc-14.2.0 --disable-multilib --enable-ld --enable-bootstrap

# Note: during configure, if an error occurs, pay attention to the system security prompt and allow the program to run as instructed. 
  
make -j 12                                                      # build: parallel build; the -j value can follow the actual number of CPU cores
make install                                     # install; install prefix: ~/develop/install/gcc-14.2.0
```
After compilation and installation, set the environment variables so the new gcc/g++ become available (put the following content in the `/home/develop/source.sh` file for convenience; use it with: `source ~/develop/source.sh`):
```
#!/bin/bash
# python3 
export PATH=~/develop/install/Python-3.13.0/bin/:$PATH

# binutils
export PATH=~/develop/install/binutils-2.43.1/bin/:$PATH

# gcc/g++ 14.2
export PATH=~/develop/install/gcc-14.2.0/bin/:$PATH
export LD_LIBRARY_PATH=~/develop/install/gcc-14.2.0/lib64/:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=~/develop/install/gcc-14.2.0/include/c++/14.2.0/:~/develop/install/gcc-14.2.0/include/c++/14.2.0/x86_64-pc-linux-gnu/:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=~/develop/install/gcc-14.2.0/include/c++/14.2.0/:~/develop/install/gcc-14.2.0/include/c++/14.2.0/x86_64-pc-linux-gnu/:$CPLUS_INCLUDE_PATH
```
4. Compile and install a newer llvm/clang/clang++ (19.1.3) from source, because the system-bundled version is too old and must be upgraded
```
#!/bin/bash
# Build requirements: 16GB RAM
cd ~/develop/src                                                              # set working directory
wget https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-19.1.3.tar.gz # download source code
tar -xzf llvmorg-19.1.3.tar.gz                                                    # extract source code
source ~/develop/source.sh                                                    # use the latest gcc/g++

# generate build configuration
cmake -S ./llvm-project-llvmorg-19.1.3/llvm/ -B ./llvm-project-llvmorg-19.1.3.build \
      -G Ninja \
      -DLLVM_ENABLE_PROJECTS="clang;lld" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_C_COMPILER=~/develop/install/gcc-14.2.0/bin/gcc \
      -DCMAKE_CXX_COMPILER=~/develop/install/gcc-14.2.0/bin/g++ \
      -DCMAKE_INSTALL_PREFIX=~/develop/install/LLVM-19.1.3

ninja -C ./llvm-project-llvmorg-19.1.3.build                                        # build source
ninja -C ./llvm-project-llvmorg-19.1.3.build install           # install; install prefix: ~/develop/install/LLVM-19.1.3

```
Set the environment variables so the new llvm/clang/clang++ become available (put the following content in the `/home/develop/source.sh` file for convenience; use it with: `source ~/develop/source.sh`):
```
#!/bin/bash
# python3 
export PATH=~/develop/install/Python-3.13.0/bin/:$PATH

# binutils
export PATH=~/develop/install/binutils-2.43.1/bin/:$PATH

# gcc/g++ 14.2
export PATH=~/develop/install/gcc-14.2.0/bin/:$PATH
export LD_LIBRARY_PATH=~/develop/install/gcc-14.2.0/lib64/:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=~/develop/install/gcc-14.2.0/include/c++/14.2.0/:~/develop/install/gcc-14.2.0/include/c++/14.2.0/x86_64-pc-linux-gnu/:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=~/develop/install/gcc-14.2.0/include/c++/14.2.0/:~/develop/install/gcc-14.2.0/include/c++/14.2.0/x86_64-pc-linux-gnu/:$CPLUS_INCLUDE_PATH

# llvm/clang/clang++
export PATH=~/develop/install/LLVM-19.1.3/bin/:$PATH
export LD_LIBRARY_PATH=~/develop/install/LLVM-19.1.3/lib/:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=~/develop/install/LLVM-19.1.3/include/:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=~/develop/install/LLVM-19.1.3/include/:$CPLUS_INCLUDE_PATH
```
5. Compile and install gn from source (no system-bundled gn was found, so build it from source):
```
#!/bin/bash
cd ~/develop/src                            # set working directory
git clone https://github.com/rhett-lee/gn.git   # download source code
cd ~/develop/src/gn                         # enter source directory
source ~/develop/source.sh                  # use the latest gcc/g++
export CXX=g++; python3 build/gen.py            # generate build configuration
ninja -C out                                    # build source
```
Set the environment variables so gn becomes available (put the following content in the `/home/develop/source.sh` file for convenience; use it with: `source ~/develop/source.sh`):
```
#!/bin/bash
# python3 
export PATH=~/develop/install/Python-3.13.0/bin/:$PATH

# binutils
export PATH=~/develop/install/binutils-2.43.1/bin/:$PATH

# gcc/g++ 14.2
export PATH=~/develop/install/gcc-14.2.0/bin/:$PATH
export LD_LIBRARY_PATH=~/develop/install/gcc-14.2.0/lib64/:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=~/develop/install/gcc-14.2.0/include/c++/14.2.0/:~/develop/install/gcc-14.2.0/include/c++/14.2.0/x86_64-pc-linux-gnu/:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=~/develop/install/gcc-14.2.0/include/c++/14.2.0/:~/develop/install/gcc-14.2.0/include/c++/14.2.0/x86_64-pc-linux-gnu/:$CPLUS_INCLUDE_PATH

# llvm/clang/clang++
export PATH=~/develop/install/LLVM-19.1.3/bin/:$PATH
export LD_LIBRARY_PATH=~/develop/install/LLVM-19.1.3/lib/:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=~/develop/install/LLVM-19.1.3/include/:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=~/develop/install/LLVM-19.1.3/include/:$CPLUS_INCLUDE_PATH

# gn
export PATH=~/develop/src/gn/out/:$PATH
```
## 3. Resource Links
1. Skia compilation documentation repository, click to visit: [skia_compile](https://github.com/rhett-lee/skia_compile)
2. nim_duilib code repository, click to visit: [nim_duilib](https://github.com/rhett-lee/nim_duilib)
