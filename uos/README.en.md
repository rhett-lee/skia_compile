English | [简体中文](README.md)

Last synced: 2026-09-28

## Downloading, Compiling, and Installing UOS Development Tools (All-in-One)
The development tools shipped with the UOS system are too old to meet requirements, so the latest versions must be built from source.    
These tools include binutils, python3, gcc/g++, llvm/clang/clang++, gn, and so on.
      
Hardware requirements:
1. Minimum memory: 16 GB; the build fails if memory is insufficient.    
2. Disk space: around 35 GB.    

How to use the script:
1. Create the working directory: `~/develop/`
2. Copy the script into the working directory and run it there. The script for this step is as follows:
```
#!/bin/bash
DEVELOP_HOME_DIR=~/develop/
mkdir -p $DEVELOP_HOME_DIR
cp ./install_development_tools.sh $DEVELOP_HOME_DIR
cd $DEVELOP_HOME_DIR
./install_development_tools.sh
```
The downloaded source code is saved in the `$DEVELOP_HOME_DIR/src` directory,    
and the compiled programs are installed in the `$DEVELOP_HOME_DIR/install` directory.    
The environment settings for the compiled development tools are saved in the `~/develop/source.sh` file.    
Because the new development tools live in their own installation directories, you must set the environment variables with `source` before using them:
```
source ~/develop/source.sh
```
