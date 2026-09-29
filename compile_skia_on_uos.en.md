English | [简体中文](compile_skia_on_uos.md)

> Last synced: 2026-09-28

# How to Build Skia from Source on UOS (UnionTech OS) Using LLVM or gcc
- Last updated: 2026-09-28
- Operating system: UOS Desktop Professional Edition AMD64 (1070 HWE version)
- Compiler: LLVM or gcc
- Note 1: This document describes how to build Skia from source on UOS (UnionTech OS) using LLVM or gcc.
- Note 2: The Skia build method described here is intended to support the [nim_duilib](https://github.com/rhett-lee/nim_duilib) project's use of the Skia library. If you use it with other libraries, you may need to adjust the build arguments.
- Note 3: After obtaining the Skia source code, some source files must be updated (see the following documents for the update method); otherwise the build will fail. (A third-party library, expat, is used.)
- Note 4: During the operations, we assume the root directory of the source code is the `~/develop` directory. If you use another directory, replace it with your actual directory.

## 1. Prerequisites 1: Install Required Software
1. After installing the system, you can upgrade it to the latest:    
   (1) `sudo apt update`    
   (2) `sudo apt upgrade -y`
2. Install the required dependencies:
```
sudo apt install -y gcc g++ gdb make git cmake python3 ninja-build wget unzip \
                    libfontconfig1-dev libgl1-mesa-dev libgles2-mesa-dev libegl1-mesa-dev libvulkan-dev 

```
The installed software versions are as follows:
```
cmake is already the newest version (3.22.1.1-1).
g++ is already the newest version (4:8.3.0-1+sign).
gcc is already the newest version (4:8.3.0-1+sign).
gdb is already the newest version (8.2.1.1-1+security).
git is already the newest version (1:2.20.1.3-2+dde).
libfontconfig1-dev is already the newest version (2.13.1.1-2+sign).
make is already the newest version (4.2.1.1-1+dde).
ninja-build is already the newest version (1.8.2-1).
python3 is already the newest version (3.7.3.1-deepin1).
unzip is already the newest version (6.0.7.2-1+deepin+sign).
libegl1-mesa-dev is already the newest version (23.1.2.3-1).
libgl1-mesa-dev is already the newest version (23.1.2.3-1).
libgles2-mesa-dev is already the newest version (23.1.2.3-1).
wget is already the newest version (1.20.1.6-deepin1).
```
Note: The download of libvulkan-dev failed and it was not installed successfully.    

## 2. Prerequisites 2: Download, Build, and Install Required Development Tools (All-in-One)
The versions of the development tools provided by the UOS system are too low to meet the requirements, so you need to build the latest versions of the development tools from source.    
These development tools include binutils, python3, gcc/g++, llvm/clang/clang++, gn, and others.    
Hardware requirements:      
1. Minimum memory: 16 GB; if memory is insufficient, the build fails.    
2. Disk space requirement: about 35 GB.    

Usage of the script:
1. Create a working directory: `~/develop/`
2. Copy the script to the working directory and run it there. The script content for this process is as follows:
```
#!/bin/bash
DEVELOP_HOME_DIR=~/develop/
mkdir -p $DEVELOP_HOME_DIR
cp ./uos/install_development_tools.sh $DEVELOP_HOME_DIR
cd $DEVELOP_HOME_DIR
./install_development_tools.sh
```
The downloaded source code is saved in the `$DEVELOP_HOME_DIR/src` directory.    
The compiled programs are installed in the `$DEVELOP_HOME_DIR/install` directory.    
The settings for the compiled development tools are saved in the `~/develop/source.sh` file.    
Because the new development tools are installed in their own directories, you must use `source` to set the environment variables before using them for them to take effect:
```
source ~/develop/source.sh
```
## 2. Build Automatically with the Script (Recommended)
This script automatically downloads the relevant source code and performs the build.    
Choose a working directory, create a script named `build.sh`, copy the prepared script below into it, and save the file.    
Then, in the console, make the script executable and run it:
```
chmod +x build.sh
./build.sh
```
The script content is as follows:    
```
#!/bin/bash
source ~/develop/source.sh

git clone https://github.com/rhett-lee/skia_compile
chmod +x ./skia_compile/linux/build_skia_all_in_one.sh
./skia_compile/linux/build_skia_all_in_one.sh
```
If fetching the skia_compile code fails during the build, you can retry a few times.    
The compiled library files are located in the `skia/out` subdirectory of the working directory, organized into the corresponding subfolders according to the build options.    
## 3. Manual Build Process
### Step 1: Obtain the Skia source code and apply the modified code
1. Get the Skia source code:    
```
#!/bin/bash
mkdir ~/develop  
cd ~/develop
git clone https://github.com/google/skia.git
git -C ./skia checkout 6f559bafbed4c8323a899df4008aa073df4eccc6
```
2. Download the source code and documents, and apply the modified Skia code:    
```
#!/bin/bash
cd ~/develop
git clone https://github.com/rhett-lee/skia_compile
unzip -o ./skia_compile/skia.2026-09-16.src.zip -d ./skia/
```
After the update, you can verify in the skia directory whether the update was applied successfully.
```
#!/bin/bash
cd ~/develop
git -C ./skia status
```
### Step 2: Build Skia (Compiler: LLVM)
1. Enter the Skia source directory:    
\> `cd ~/develop/skia`    
\> `source ~/develop/source.sh`    
2. Build the Skia static library (llvm.x64.release)
 - gn gen out/llvm.x64.release --args="target_cpu=\"x64\" cc=\"clang\" cxx=\"clang++\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false skia_use_partition_alloc=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\"]"    
 - ninja -C out/llvm.x64.release`
### Step 2: Build Skia (Compiler: gcc/g++, if you do not use the LLVM compiler, you can also build with gcc/g++)
1. Enter the Skia source directory:    
\> `cd ~/develop/skia`    
\> `source ~/develop/source.sh`    
2. Build the Skia static library (gcc.x64.release)
 - gn gen out/gcc.x64.release --args="target_cpu=\"x64\" cc=\"gcc\" cxx=\"g++\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false skia_use_partition_alloc=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\"]"    
 - ninja -C out/gcc.x64.release`
## 4. Resource Links
1. Skia build documentation repository - for the latest documentation, please visit: [skia_compile](https://github.com/rhett-lee/skia_compile)     
2. nim_duilib GUI library code repository, please visit: [nim_duilib](https://github.com/rhett-lee/nim_duilib)     
nim_duilib is a cross-platform GUI library developed in C++, derived from the classic duilib GUI library and deeply optimized and extended. It supports Windows/Linux/macOS/FreeBSD; the supported Linux distributions include OpenEuler, OpenKylin, UbuntuKylin, UOS, NeoKylin, Ubuntu, Fedora, Debian, and others. It focuses on simplifying efficient desktop application development. Its design incorporates the DirectUI philosophy, using XML to describe the UI layout and separating visuals from logic, which significantly improves development flexibility and maintainability.