English | [简体中文](compile_skia_on_freebsd.md)

> Last synced: 2026-09-28

# How to Build Skia from Source on FreeBSD Using clang/clang++
- Last updated: 2026-09-28
- Operating system: FreeBSD
- Compiler: clang/clang++
- Note 1: This document describes how to build Skia from source on FreeBSD using clang/clang++.
- Note 2: The Skia build method described here is intended to support the [nim_duilib](https://github.com/rhett-lee/nim_duilib) project's use of the Skia library. If you use it with other libraries, you may need to adjust the build arguments.
- Note 3: After obtaining the Skia source code, some source files must be updated (see the following documents for the update method); otherwise the build will fail. (Three third-party libraries are used: expat, freetype2, and fontconfig.)
- Note 4: During the operations, we assume the root directory of the source code is the `~/develop` directory. If you use another directory, replace it with your actual directory.

## 1. Prerequisites: Install Required Software
```
sudo pkg install git unzip python3 cmake ninja gn llvm fontconfig freetype2
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
#!/usr/bin/env bash

git clone https://github.com/rhett-lee/skia_compile
chmod +x ./skia_compile/freebsd/build_skia_all_in_one.sh
./skia_compile/freebsd/build_skia_all_in_one.sh
```
If fetching the skia_compile code fails during the build, you can retry a few times.
The compiled library files are located in the `skia/out` subdirectory of the working directory, organized into the corresponding subfolders according to the build options.
## 3. Manual Build Process
### Step 1: Obtain the Skia source code and apply the modified code
1. Get the Skia source code:
```
#!/usr/bin/env bash
cd ~/develop
git clone https://github.com/google/skia.git
git -C ./skia checkout 6f559bafbed4c8323a899df4008aa073df4eccc6
```
2. Download the source code and documents, and apply the modified Skia code:
```
#!/usr/bin/env bash
cd ~/develop
git clone https://github.com/rhett-lee/skia_compile
unzip -o ./skia_compile/skia.2026-09-16.src.zip -d ./skia/
```
After the update, you can verify in the skia directory whether the update was applied successfully.
```
#!/usr/bin/env bash
cd ~/develop/
git -C ./skia status
```
### Step 2: Build Skia (Compiler: LLVM)
1. Enter the Skia source directory:
```
cd ~/develop/skia
```
Make sure the fontconfig and freetype2 header files and library files are in the following paths:
```
/usr/local/include/freetype2 
/usr/local/include
/usr/local/lib 
```
Otherwise, modify the actual paths in the arguments.
```
extra_ldflags = [ \"-L/usr/local/lib\" ]
extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\", \"-I/usr/local/include/freetype2\", \"-I/usr/local/include\"]
```
2. Build the Skia static library (llvm.arm64.release)
 - gn gen out/llvm.arm64.release --args="target_cpu=\"arm64\" ar=\"llvm-ar\" skia_enable_fontmgr_fontconfig=true skia_use_freetype=true extra_ldflags = [ \"-L/usr/local/lib\" ] cc=\"clang\" cxx=\"clang++\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false skia_use_partition_alloc=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\", \"-I/usr/local/include/freetype2\", \"-I/usr/local/include\"]"
 - ninja -C out/llvm.arm64.release`
3. Build the Skia static library (llvm.x64.release)
 - gn gen out/llvm.x64.release --args="target_cpu=\"x64\" ar=\"llvm-ar\" skia_enable_fontmgr_fontconfig=true skia_use_freetype=true extra_ldflags = [ \"-L/usr/local/lib\" ] cc=\"clang\" cxx=\"clang++\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false skia_use_partition_alloc=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\", \"-I/usr/local/include/freetype2\", \"-I/usr/local/include\"]"
 - ninja -C out/llvm.x64.release`
## 4. Resource Links
1. Skia build documentation repository - for the latest documentation, please visit: [skia_compile](https://github.com/rhett-lee/skia_compile)
2. nim_duilib GUI library code repository, please visit: [nim_duilib](https://github.com/rhett-lee/nim_duilib)
nim_duilib is a cross-platform GUI library developed in C++, derived from the classic duilib GUI library and deeply optimized and extended. It supports Windows/Linux/macOS/FreeBSD; the supported Linux distributions include OpenEuler, OpenKylin, UbuntuKylin, UOS, NeoKylin, Ubuntu, Fedora, Debian, and others. It focuses on simplifying efficient desktop application development. Its design incorporates the DirectUI philosophy, using XML to describe the UI layout and separating visuals from logic, which significantly improves development flexibility and maintainability.