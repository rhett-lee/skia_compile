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
cmake 已经是最新版 (3.22.1.1-1)。
g++ 已经是最新版 (4:8.3.0-1+sign)。
gcc 已经是最新版 (4:8.3.0-1+sign)。
gdb 已经是最新版 (8.2.1.1-1+security)。
git 已经是最新版 (1:2.20.1.3-2+dde)。
make 已经是最新版 (4.2.1.1-1+dde)。
ninja-build 已经是最新版 (1.8.2-1)。
python3 已经是最新版 (3.7.3.1-deepin1)。
unzip 已经是最新版 (6.0.7.2-1+deepin+sign)。
wget 已经是最新版 (1.20.1.6-deepin1)。
```
Note: the development tool versions provided by the system by default are too old. When they cannot meet requirements, you must build the latest versions of the development tools from source, including binutils, python3, gcc/g++, llvm/clang/clang++, gn, and so on.

# 2. Manually Compile and Install the Development Environment from Source
Minimum memory requirement: 16 GB; the build fails if memory is insufficient.
Disk space requirement: around 35 GB.

1. Compile and install the latest binutils (the system-bundled version is too old; linking gcc/g++/llvm/clang/clang++ with ld/gold causes errors)
```
#!/bin/bash
cd ~/develop; mkdir src                                  #创建源码目录
cd ~/develop/src                                         #设置工作目录
wget https://ftp.gnu.org/gnu/binutils/binutils-2.43.1.tar.gz #下载源码
tar -xzf binutils-2.43.1.tar.gz                              #解压源码
cd binutils-2.43.1                                           #进入源码目录
./configure --prefix=~/develop/install/binutils-2.43.1/ --disable-werror --enable-gprofng=no #运行配置脚本
  #备注：使用`--enable-gprofng=no`选项是因为gprofng的源码有编译错误。    
make                                                         #编译
make install                                                 #安装

```
2. Compile and install a newer python3 (3.13.0) from source, because the system-bundled version (3.7.3) is too old to compile llvm and must be upgraded
```
#!/bin/bash
cd ~/develop/src                                                #设置工作目录
wget https://www.python.org/ftp/python/3.13.0/Python-3.13.0.tar.xz  #下载源码
tar -xJf Python-3.13.0.tar.xz                                       #解压源码
cd Python-3.13.0                                                    #进入源码目录
./configure --prefix=~/develop/install/Python-3.13.0/           #运行配置脚本
make                                                                #编译
make install                                                        #安装, 会遇到错误，但不影响。
```
3. Compile and install a newer gcc/g++ (14.2.0) from source, because the system-bundled version is too old and must be upgraded
```
#!/bin/bash
# 编译资源需求：4GB内存，磁盘空间：12GB

cd ~/develop/src                                            #设置工作目录
wget https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.gz   #下载源码
tar -xzf gcc-14.2.0.tar.gz                                      #解压源码
cd ~/develop/src/gcc-14.2.0                                 #进入gcc-14.2.0源码目录
./contrib/download_prerequisites                                #下载编译时依赖的第三方库

#配置（说明：由于UOS自带的ld(v2.31.1)链接gcc/g++时失败，所以使用源码编译安装的最新版ld(v2.43.1)）
mkdir -p ~/develop/src/gcc-14.2.0.build
cd ~/develop/src/gcc-14.2.0.build
export LD="~/develop/install/binutils-2.43.1/bin/ld"
../gcc-14.2.0/configure --prefix=~/develop/install/gcc-14.2.0 --disable-multilib --enable-ld --enable-bootstrap

#注意：运行configure的过程中，如果遇到错误，请留意系统的安全拦截提示，按照安全拦截提示，允许任意程序执行即可。 
  
make -j 12                                                      #编译：多进程编译，编译参数可参考电脑实际有几个核心
make install                                     #安装，安装目录为：~/develop/install/gcc-14.2.0
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
#编译资源需求：16GB内存
cd ~/develop/src                                                              #设置工作目录
wget https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-19.1.3.tar.gz #下载源码
tar -xzf llvmorg-19.1.3.tar.gz                                                    #解压源码
source ~/develop/source.sh                                                    #使用gcc/g++最新版

#生成编译配置
cmake -S ./llvm-project-llvmorg-19.1.3/llvm/ -B ./llvm-project-llvmorg-19.1.3.build \
      -G Ninja \
      -DLLVM_ENABLE_PROJECTS="clang;lld" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_C_COMPILER=~/develop/install/gcc-14.2.0/bin/gcc \
      -DCMAKE_CXX_COMPILER=~/develop/install/gcc-14.2.0/bin/g++ \
      -DCMAKE_INSTALL_PREFIX=~/develop/install/LLVM-19.1.3

ninja -C ./llvm-project-llvmorg-19.1.3.build                                        #编译源码
ninja -C ./llvm-project-llvmorg-19.1.3.build install           #安装，安装目录为:~/develop/install/LLVM-19.1.3

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
cd ~/develop/src                            #设置工作目录
git clone https://github.com/rhett-lee/gn.git   #下载源码
cd ~/develop/src/gn                         #进入源码目录
source ~/develop/source.sh                  #使用gcc/g++最新版
export CXX=g++; python3 build/gen.py            #生成编译配置
ninja -C out                                    #编译源码
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
