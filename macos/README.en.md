English | [简体中文](README.md)

Last synced: 2026-09-28

## Build Skia with a Script (All-in-One)
Pick a working directory, create a script `build.sh`, copy the prepared script below into it, and save the file.
Then, in the console, make the script executable and finally run it:
```
chmod +x build.sh
./build.sh
```
The script file contents are as follows:
```
#!/bin/bash

git clone https://github.com/rhett-lee/skia_compile
chmod +x ./skia_compile/macos/build_skia_all_in_one.sh
./skia_compile/macos/build_skia_all_in_one.sh
```
If fetching the skia_compile code fails during compilation, retry a few times.
The compiled libraries are placed in the `skia/out` subdirectory of the working directory, in subfolders organized by build option.
