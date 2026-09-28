English | [简体中文](compile_skia_on_windows_mingw64.md)

> Last synced: 2026-09-28

# How to Build Skia from Source on Windows Using MinGW-W64 (gcc/g++ or LLVM)

- Last updated: 2026-09-16
- Operating system: Windows 11 64-bit
- Compiler: MinGW-W64 gcc/g++ or LLVM-MinGW
- Note 1: This document describes how to build Skia from source on Windows using MinGW-W64 (gcc/g++) or LLVM-MinGW.
- Note 2: The Skia build method described here is intended to support the [nim\_duilib](https://github.com/rhett-lee/nim_duilib) project's use of the Skia library. If you use it with other libraries, you may need to adjust the build arguments.
- Note 3: After obtaining the Skia source code, some source files must be updated (see the following documents for the update method); otherwise the build will fail. (A third-party library, `expat`, is used.)
- Note 4: During the operations, we assume the root directory of the source code is `D:/develop`. If you use another directory, replace it with your actual directory.

## 1. Prerequisites: Install Required Software

1. Install Python v3.11.x (if Python v3 is already installed on your machine, you can skip this step)    
     
   (The Python major version must be v3, and it must be added to the Path environment variable so that `python.exe` can be launched directly)    
     
   (1) First, install Python.    
     
   (2) In Windows Settings, turn off the "App execution aliases" for `python.exe` and `python3.exe`; otherwise the Skia build script will have problems. Windows Settings path: Settings -> Apps -> Advanced app settings -> App execution aliases.    
     
   (3) Go to the directory where `python.exe` is located, make a copy of `python.exe` and rename it to `python3.exe`, so that `python3.exe` can be invoked from the command line.
     
   (4) Verify: ensure `python.exe` and `python3.exe` can be invoked from the command line.    
2. Install git (if git is already installed on your machine, you can skip this step)    
     
   (git must be added to the Path environment variable so that `git.exe` can be invoked from the command line)    
     
   (1) Git For Windows: version 2.44    
     
   (2) TortoiseGit: version 2.15    
3. Obtain the MinGW-w64 build environment (if MinGW-w64 is already installed on your machine, you can skip this step)    
     
   (1) Download page: <https://www.mingw-w64.org/downloads/>    
     
   (2) mingw64 LLVM (recommended)
     
   Download page: <https://github.com/mstorsjo/llvm-mingw/releases>    
     
   Download link: <https://github.com/mstorsjo/llvm-mingw/releases/download/20250430/llvm-mingw-20250430-ucrt-x86_64.zip>    
     
   After downloading, extract to the directory `C:/mingw64`; the final gcc/g++ directory is `C:/mingw64/llvm-mingw-20250430-ucrt-x86_64/bin`
     
   (3) mingw64 gcc/g++    
     
   Download page: <https://github.com/niXman/mingw-builds-binaries/releases>    
     
   Download link: <https://github.com/niXman/mingw-builds-binaries/releases/download/15.1.0-rt_v12-rev0/x86_64-15.1.0-release-win32-seh-ucrt-rt_v12-rev0.7z>    
        
   After downloading, extract to the directory `C:/mingw64`; the final gcc/g++ directory is `C:/mingw64/x86_64-15.1.0-release-win32-seh-ucrt-rt_v12-rev0/mingw64/bin`

## 2. Build Automatically with the Script (Recommended)

This script automatically downloads the relevant source code and performs the build.    
  
Choose a working directory, create a script named `build.bat`, copy the prepared script below into it, and save the file.    
    
The script content is as follows:

```
echo OFF
set retry_delay=10
:retry_clone_skia_compile
if not exist ".\skia_compile" (
    git clone https://github.com/rhett-lee/skia_compile
) else (     
    git -C ./skia_compile pull
)
if %errorlevel% neq 0 (
    timeout /t %retry_delay% >nul
    goto retry_clone_skia_compile
)

.\skia_compile\mingw64\build_skia_all_in_one.bat
```
    
Open a command-line console and set the PATH environment variable (if the build environment is already added to the PATH variable, you can skip this step):

```
SET PATH=%PATH%;C:\mingw64\llvm-mingw-20250430-ucrt-x86_64\bin
```

Finally, run the script:

```
.\build.bat
```

If fetching the skia_compile code fails during the build, you can retry a few times.    
  
The compiled library files are located in the `skia/out` subdirectory of the working directory, organized into the corresponding subfolders according to the build options.    

## 3. Manual Build Process

### Step 1: Obtain the Skia source code and the modified source code

1. Get the Skia source code:    
     
   (1) `> mkdir D:/develop`    
     
   (2) `> cd /d D:/develop`    
     
   (3) `> git clone https://github.com/google/skia.git`    
     
   (4) `> git checkout 6f559bafbed4c8323a899df4008aa073df4eccc6`       
2. Apply the modified code:    
    
   (1) `> cd /d D:/develop`
     
   (2) `> git clone https://github.com/rhett-lee/skia_compile` (downloads the source code and documents)    
     
   (3) Extract `skia.2026-09-16.src.zip` into the directory `skia.2026-09-16.src`    
     
   (4) Copy all the contents of the directory `skia.2026-09-16.src` into the `D:/develop/skia` directory, overwriting all files with the same name    
     
   (5) Note: the SHA-1 of the modified code must be compared. If it is not this version of the code, overwriting directly may cause problems.    

### Step 2: Build Skia (Compiler: mingw64 LLVM) (Recommended)    

1. Run the cmd.exe command-line environment.
2. Set the PATH environment variable:    
     
   `> `SET PATH=%PATH%;C:\mingw64\llvm-mingw-20250430-ucrt-x86_64\bin\`\`    
     
   `> clang++ -v`
3. Enter the Skia source directory:    
     
   `> cd /d D:/develop/skia`
4. Build the Skia static library (mingw64 LLVM, x64)    

- `.\bin\gn.exe gen out/mingw64-llvm.x64.release --args="target_cpu=\"x64\" cc=\"clang\" cxx=\"clang++\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false skia_use_partition_alloc=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\"]"`    
- `.\bin\ninja.exe -C out/mingw64-llvm.x64.release`    

1. Build the Skia static library (mingw64 LLVM, x86)    

- `.\bin\gn.exe gen out/mingw64-llvm.x86.release --args="target_cpu=\"x86\" cc=\"clang\" cxx=\"clang++\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false skia_use_partition_alloc=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\"]"`    
- `.\bin\ninja.exe -C out/mingw64-llvm.x86.release`    

### Step 2: Build Skia (Compiler: mingw64 gcc/g++)

1. Run the cmd.exe command-line environment.
2. Set the PATH environment variable:
     
   `> `SET PATH=%PATH%;C:\mingw64\llvm-mingw-20250430-ucrt-x86_64\bin`    `` `> g++ -v\`    
3. Enter the Skia source directory:
     
   `> cd /d D:/develop/skia`
4. Build the Skia static library (mingw64 gcc/g++, x64)    

- `.\bin\gn.exe gen out/mingw64-gcc.x64.release --args="target_cpu=\"x64\" cc=\"gcc\" cxx=\"g++\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false skia_use_partition_alloc=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\"]"`    
- `.\bin\ninja.exe -C out/mingw64-gcc.x64.release`

1. Build the Skia static library (mingw64 gcc/g++, x86)    

- `.\bin\gn.exe gen out/mingw64-gcc.x86.release --args="target_cpu=\"x86\" cc=\"gcc\" cxx=\"g++\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false skia_use_partition_alloc=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\"]"`    
- `.\bin\ninja.exe -C out/mingw64-gcc.x86.release`    

## 4. Resource Links

1. Skia build documentation repository - for the latest documentation, please visit: [skia\_compile](https://github.com/rhett-lee/skia_compile)     
2. nim_duilib GUI library code repository, please visit: [nim\_duilib](https://github.com/rhett-lee/nim_duilib)     
     
   nim_duilib is a cross-platform GUI library developed in C++, derived from the classic duilib GUI library and deeply optimized and extended. It supports Windows/Linux/macOS/FreeBSD; the supported Linux distributions include OpenEuler, OpenKylin, UbuntuKylin, UOS, NeoKylin, Ubuntu, Fedora, Debian, and others. It focuses on simplifying efficient desktop application development. Its design incorporates the DirectUI philosophy, using XML to describe the UI layout and separating visuals from logic, which significantly improves development flexibility and maintainability.
