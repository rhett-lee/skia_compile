English | [简体中文](README.md)

Last synced: 2026-09-28

# Files in This Directory
## Build Skia with a Script (All-in-One)
### Usage of the `build_skia_all_in_one.bat` File
Pick a working directory, create a script `build_skia.bat`, copy the prepared script below into it, and save the file.
```
git clone https://github.com/rhett-lee/skia_compile
.\skia_compile\windows\build_skia_all_in_one.bat
```
The script above uses the static runtime. If you need the dynamic-link library, add the `/MD` parameter and run the script again:
```
git clone https://github.com/rhett-lee/skia_compile
.\skia_compile\windows\build_skia_all_in_one.bat /MD
```
Open a command-line console and run the script:
```
.\build_skia.bat
```
If fetching the skia_compile code fails during compilation, retry a few times.
The compiled libraries are placed in the `skia/out` subdirectory of the working directory, in subfolders organized by build option.

## Three Executable Files
1. `bin/ninja.exe`
   (1) Version: v1.13.2
   (2) Source: downloaded from the official website
   (3) Download URL: `https://github.com/ninja-build/ninja/releases/download/v1.13.2/ninja-win.zip`
   (4) This is an x64 program

2. `bin/gn.exe`
   (1) Version: 2026-03-22
   (2) Source: built from source at `https://github.com/rhett-lee/gn/`
   (3) Build method is described below.
   (4) This is an x64 program

3. `bin/miniunz.exe`
   (1) Version: 1.3.1
   (2) Source: built from the source at `nim_duilib/duilib/third_party/zlib/contrib/vstudio/vc17/zlibvc.sln`. You must first change the `zlibvc` project from DLL to lib, then build it.
   (3) This is an x86 program

# Building `bin/gn.exe` (gn.exe is required when compiling Skia source)
1. Download the source: `https://github.com/rhett-lee/gn.git`
   (1) > `cd /d D:\develop` (assume this is the development directory)
   (2) > `git clone https://github.com/rhett-lee/gn.git`
2. Build gn (note: VS 2022 already ships ninja.exe if you selected the CMake extension during installation):
   (1) First, open the VS 2022 command-line build environment (x64 Native Tools Command Prompt for VS 2022)
   (2) Enter the gn source directory: `cd /d D:\develop\gn`
   (3) > `python build/gen.py`
   (4) > `ninja -C out`
