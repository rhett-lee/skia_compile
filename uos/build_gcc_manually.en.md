English | [简体中文](build_gcc_manually.md)

Last synced: 2026-09-28

# How to Compile gcc Manually
When the system's bundled gcc/g++ version is too old and does not support C++20, you can compile the latest gcc/g++ from source manually.

## Preparation: Install Required Software
Install the prerequisite software:    
    `sudo apt install -y gcc g++ gdb make wget`    

## Download Source and Build the Latest gcc/g++
(1) Assume the working directory is: `~/develop`    
(2) Create the source directory: `mkdir src; cd src`    
(3) Enter the working directory: `~/develop/src`    
(4) Download: `wget https://ftp.gnu.org/gnu/gcc/gcc-15.1.0/gcc-15.1.0.tar.gz`    
(5) Extract: `tar -xzf gcc-15.1.0.tar.gz`    
(6) Download the third-party libraries gcc depends on: enter the gcc-15.1.0 directory, then download the dependencies    
    `cd ~/develop/src/gcc-15.1.0`    
    `./contrib/download_prerequisites`    
(7) Configure:    
    `mkdir -p ~/develop/src/gcc-15.1.0.build`    
    `cd ~/develop/src/gcc-15.1.0.build`    
    `../gcc-15.1.0/configure --prefix=~/develop/install/gcc-15.1.0 --disable-multilib --enable-ld --enable-bootstrap`    
(8) Compile: `make -j 4` (parallel build; the job count can be set according to the actual number of CPU cores).    
(9) Install: `make install`    
(10) Set environment variables so the new gcc/g++ becomes available:    
    `export PATH=~/develop/install/gcc-15.1.0/bin/:$PATH`    
    `export LD_LIBRARY_PATH=~/develop/install/gcc-15.1.0/lib64/:$LD_LIBRARY_PATH`    
    `export C_INCLUDE_PATH=~/develop/install/gcc-15.1.0/include/c++/15.1.0/:~/develop/install/gcc-15.1.0/include/c++/15.1.0/x86_64-pc-linux-gnu/:$C_INCLUDE_PATH`    
    `export CPLUS_INCLUDE_PATH=~/develop/install/gcc-15.1.0/include/c++/15.1.0/:~/develop/install/gcc-15.1.0/include/c++/15.1.0/x86_64-pc-linux-gnu/:$CPLUS_INCLUDE_PATH`    

## Resource Links
1. Skia compilation documentation repository, click to visit: [skia_compile](https://github.com/rhett-lee/skia_compile)
2. nim_duilib code repository, click to visit: [nim_duilib](https://github.com/rhett-lee/nim_duilib)
