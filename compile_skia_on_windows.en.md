English | [简体中文](compile_skia_on_windows.md)

> Last synced: 2026-09-28

# How to Build Skia from Source on Windows Using LLVM
- Last updated: 2026-09-16
- Operating system: Windows 11 64-bit
- Windows SDK: version 10.0.26100.0 (this is the Windows 11 SDK; nim_duilib's CEF module depends on the Windows 11 SDK, and the Windows 10 SDK will fail to compile the CEF-related modules. If you do not use the CEF feature, the Windows 10 SDK is also acceptable)
- Microsoft Visual Studio: 2022 or 2026 (**If you use VS2017/VS2019, please use the `develop-cpp17` branch; the main branch does not support VS2017/VS2019**)
- Compiler: LLVM
- Note 1: This document describes how to build Skia from source on Windows using LLVM.
- Note 2: The Skia build method described here is intended to support the [nim_duilib](https://github.com/rhett-lee/nim_duilib) project's use of the Skia library. If you use it with other libraries, you may need to adjust the build arguments.
- Note 3: To improve the runtime performance of the Debug build, the Debug build uses the same build arguments as the Release build, except that the runtime library is changed from `/MT` to `/MTd`.
- Note 4: After obtaining the Skia source code, some source files must be updated (see the following documents for the update method); otherwise the build will fail. (A third-party library, `expat`, is used.)
- Note 5: During the operations, we assume the root directory of the source code is `D:/develop`. If you use another directory, replace it with your actual directory.

## 1. Prerequisites: Install Required Software
1. Install python3 (the Python major version must be 3, and it must be added to the Path environment variable)    
   (1) First, install python3.    
   (2) Go to the directory where `python.exe` is located, make a copy of `python.exe` and rename it to `python3.exe`, so that `python3.exe` can be invoked from the command line.
   (3) Verify on the command line: `> python3.exe --version` prints the Python version.     
2. Install Git For Windows: version 2.44 (a higher version is also fine). Git must be added to the Path environment variable so that `git.exe` can be invoked from the command line.    
3. Install Visual Studio 2022 Community or Visual Studio 2026 Community (optional)    
   - If multiple versions of Visual Studio are installed on the machine, the highest version is selected by default.    
     If you need to change the Visual Studio version used for the build, you can specify the exact VS path with the `win_vc` argument (manual build required), for example:    
     `\"C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\" target_cpu=\"x64\" ... `    
   - If multiple versions of the Windows SDK are installed, the highest version is selected by default.    
     If you need to specify a particular Windows SDK version, use the `win_sdk_version` argument (manual build required), for example:    
     `\"10.0.26100.0\" target_cpu=\"x64\" ... `    
     The default installation path of the Windows SDK is `C:/Program Files (x86)\Windows Kits\10\Include`; all Windows SDK versions installed on the machine can be viewed in this directory.    
   - If Visual Studio has multiple versions of the toolset installed, the highest version is selected by default.    
     If you need to specify the toolset version, use the `win_toolchain_version` argument (manual build required), for example:    
     `\"14.51.36231\" target_cpu=\"x64\" ... `    
4. Install LLVM: version 21.1.4 Win64    
   (1) Installation directory: `C:/LLVM`    
   (2) Note: the installation directory must not contain spaces, otherwise the build will encounter problems.

## 2. Build Automatically with the Script (Recommended)    
This script automatically downloads the relevant source code and performs the build.    
Choose a working directory (Note: the path must not contain spaces, otherwise the build script will error), create a script named `build_skia.bat`, copy the prepared script below into it, and save the file.    
- For Visual Studio 2022/2026, the script content is as follows:    
```
REM For Visual Studio 2022/2026
echo OFF
set retry_delay=10
:retry_clone_skia_compile
if not exist ".\skia_compile\.git" (
    git clone https://github.com/rhett-lee/skia_compile
) else (       
    git -C ./skia_compile pull
)
if %errorlevel% neq 0 (
    timeout /t %retry_delay% >nul
    goto retry_clone_skia_compile
)
if not exist ".\skia_compile\.git" (
    echo clone skia_compile failed!
    exit /b 1
)

.\skia_compile\windows\build_skia_all_in_one.bat
```

The script above builds with the static runtime (`/MT` and `/MTd`) by default. If you need to use the dynamic runtime (`/MD` and `/MDd`), append the `/MD` argument to the last line of the script above, changing it to:    
`.\skia_compile\windows\build_skia_all_in_one.bat /MD`    
Note: if nim_duilib is eventually built as a DLL, you must use the dynamic runtime.    

- For Visual Studio 2017/2019, the script content is as follows:    
```
REM For Visual Studio 2017/2019
echo OFF
set retry_delay=10
:retry_clone_skia_compile
if not exist ".\skia_compile\.git" (
    git clone https://github.com/rhett-lee/skia_compile
) else (       
    git -C ./skia_compile pull
)
if %errorlevel% neq 0 (
    timeout /t %retry_delay% >nul
    goto retry_clone_skia_compile
)
if not exist ".\skia_compile\.git" (
    echo clone skia_compile failed!
    exit /b 1
)

:retry_pull_skia_compile
git -C ./skia_compile checkout develop-cpp17
git -C ./skia_compile pull
if %errorlevel% neq 0 (
    timeout /t %retry_delay% >nul
    goto retry_pull_skia_compile
)

.\skia_compile\windows\build_skia_all_in_one.bat
```

The script above builds with the static runtime (`/MT` and `/MTd`) by default. If you need to use the dynamic runtime (`/MD` and `/MDd`), append the `/MD` argument to the last line of the script above, changing it to:    
`.\skia_compile\windows\build_skia_all_in_one.bat /MD`    
Note: if nim_duilib is eventually built as a DLL, you must use the dynamic runtime.    

- Open a command-line console and run the script:
```
.\build_skia.bat
```

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

### Step 2: Build Skia (Compiler: LLVM)
#### (1) Build the 64-bit library (x64)
1. First open the command prompt (cmd.exe)
2. Enter the Skia source directory:    
   `> cd /d D:/develop/skia`    
3. If you are using VS2026, you can change `--ide="vs2022"` to `--ide="vs2026"` in the command lines below.     
4. Build the Skia library (llvm.x64.debug, static runtime by default; for dynamic runtime, manually change `/MTd` to `/MDd` in the command-line arguments)
 - `.\bin\gn.exe gen out/llvm.x64.debug --ide="vs2022" --sln="skia" --args="target_cpu=\"x64\" cc=\"clang\" cxx=\"clang++\" clang_win=\"C:/LLVM\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false skia_use_partition_alloc=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\",\"/MTd\"]"`    
 - `.\bin\ninja.exe -C out/llvm.x64.debug`    (If you need to rebuild, you can clean first with: `.\bin\ninja.exe -C out/llvm.x64.debug -t clean`)    

5. Build the Skia library (llvm.x64.release, static runtime by default; for dynamic runtime, manually change `/MT` to `/MD` in the command-line arguments)
 - `.\bin\gn.exe gen out/llvm.x64.release --ide="vs2022" --sln="skia" --args="target_cpu=\"x64\" cc=\"clang\" cxx=\"clang++\" clang_win=\"C:/LLVM\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false skia_use_partition_alloc=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\",\"/MT\"]"`    
 - `.\bin\ninja.exe -C out/llvm.x64.release`

#### (2) Build the 32-bit library (x86)
1. First open the command prompt (cmd.exe)
2. Enter the Skia source directory:    
   `> cd /d D:/develop/skia`    
3. If you are using VS2026, you can change `--ide="vs2022"` to `--ide="vs2026"` in the command lines below.     
4. Build the Skia library (llvm.x86.release, static runtime by default; for dynamic runtime, manually change `/MT` to `/MD` in the command-line arguments)
 - `.\bin\gn.exe gen out/llvm.x86.release --ide="vs2022" --sln="skia" --args="target_cpu=\"x86\" cc=\"clang\" cxx=\"clang++\" clang_win=\"C:/LLVM\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false skia_use_partition_alloc=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\",\"/MT\"]"`    
 - `.\bin\ninja.exe -C out/llvm.x86.release`
5. Build the Skia library (llvm.x86.debug, static runtime by default; for dynamic runtime, manually change `/MTd` to `/MDd` in the command-line arguments)
 - `.\bin\gn.exe gen out/llvm.x86.debug --ide="vs2022" --sln="skia" --args="target_cpu=\"x86\" cc=\"clang\" cxx=\"clang++\" clang_win=\"C:/LLVM\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false skia_use_partition_alloc=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\",\"/MTd\"]"`    
 - `.\bin\ninja.exe -C out/llvm.x86.debug`

## 4. Why Build Skia with LLVM    
Because code compiled with LLVM has noticeably better execution performance than code compiled with VS.    
Code compiled with VS shows obvious stuttering at runtime.    

## 5. Resource Links
1. Skia build documentation repository - for the latest documentation, please visit: [skia_compile](https://github.com/rhett-lee/skia_compile)     
2. nim_duilib GUI library code repository, please visit: [nim_duilib](https://github.com/rhett-lee/nim_duilib)     
nim_duilib is a cross-platform GUI library developed in C++, derived from the classic duilib GUI library and deeply optimized and extended. It supports Windows/Linux/macOS/FreeBSD; the supported Linux distributions include OpenEuler, OpenKylin, UbuntuKylin, UOS, NeoKylin, Ubuntu, Fedora, Debian, and others. It focuses on simplifying efficient desktop application development. Its design incorporates the DirectUI philosophy, using XML to describe the UI layout and separating visuals from logic, which significantly improves development flexibility and maintainability.
