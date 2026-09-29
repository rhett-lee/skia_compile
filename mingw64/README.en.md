English | [简体中文](README.md)

Last synced: 2026-09-28

## Build Skia with a Script (All-in-One)
Pick a working directory, create a script `build.bat`, copy the prepared script below into it, and save the file.    
```
git clone https://github.com/rhett-lee/skia_compile
.\skia_compile\mingw64\build_skia_all_in_one.bat
```
Open a command-line console and set the PATH environment variable (skip this step if the build environment is already on PATH):    
```
SET PATH=%PATH%;C:\mingw64\llvm-mingw-20250430-ucrt-x86_64\bin
```
Finally, run the script:
```
.\build.bat
```
If fetching the skia_compile code fails during compilation, retry a few times.    
The compiled libraries are placed in the `skia/out` subdirectory of the working directory, in subfolders organized by build option.    
