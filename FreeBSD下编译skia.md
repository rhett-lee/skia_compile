# FreeBSD系统中使用clang/clang++编译Skia源码的方法
 - 修改日期：2026-02-10
 - 操作系统：FreeBSD
 - 编译器：clang/clang++
 - 说明1：本文档介绍FreeBSD系统中使用clang/clang++编译Skia源码的方法
 - 说明2：该编译Skia源码的方法，是为了适配[nim_duilib](https://github.com/rhett-lee/nim_duilib)项目使用Skia库，如果用于其他库使用，可能需要修改编译参数
 - 说明3：获取skia源码后，需要更新部分源码（更新方法见后续文档），否则编译无法通过。（使用了三个第三方库：expat，freetype2，fontconfig）
 - 说明4：操作过程中，假设源码的根目录是`~/develop`目录，如果使用其他目录，可替换为实际的目录。

## 一、准备工作：安装必备的软件
```
sudo pkg install git unzip python3 cmake ninja gn llvm fontconfig freetype2
```
## 二、使用脚本自动编译（推荐）
该脚本自动完成相关源码下载和编译工作。    
选定一个工作目录，创建一个脚本`build.sh`，将下面已经整理好脚本复制进去，保存文件。    
然后在控制台，为脚本文件添加可执行权限，最后运行该脚本： 
```
chmod +x build.sh
./build.sh
```

脚本文件内容如下：    
```
#!/usr/bin/env bash

git clone https://github.com/rhett-lee/skia_compile
chmod +x ./skia_compile/freebsd/build_skia_all_in_one.sh
./skia_compile/freebsd/build_skia_all_in_one.sh
```
编译时如果获取skia_compile代码失败，可以多重试几次。    
编译完成的库文件在工作目录的`skia/out`子目录中，按编译选项放在相应的子目录。    

## 三、手动编译过程
### 第1步：获取skia源码并更新修改代码
1. 获取skia源码：    
```
#!/usr/bin/env bash
cd ~/develop
git clone https://github.com/google/skia.git
git -C ./skia checkout 34aa71b8bee4648a442b7125680232d803374f19
```
2. 下载源码和文档，并更新skia的修改代码：    
```
#!/usr/bin/env bash
cd ~/develop
git clone https://github.com/rhett-lee/skia_compile
unzip -o ./skia_compile/skia.2026-02-10.src.zip -d ./skia/
``` 
更新完成后，可以到skia目录中确认一下是否更新成功
```
#!/usr/bin/env bash
cd ~/develop/
git -C ./skia status
```

### 第2步：编译skia（编译器：LLVM）
1. 进入skia源码目录：
```
cd ~/develop/skia
```
确定fontconfig和freetype2头文件和库文件在下面的路径中
```
/usr/local/include/freetype2 
/usr/local/include
/usr/local/lib 
```
否则修改参数的实际路径
```
extra_ldflags = [ \"-L/usr/local/lib\" ]
extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\", \"-I/usr/local/include/freetype2\", \"-I/usr/local/include\"]
```
2. 编译skia静态库（llvm.arm64.Release）
 - `gn gen out/llvm.arm64.release --args="target_cpu=\"arm64\" ar=\"llvm-ar\" skia_enable_fontmgr_fontconfig=true skia_use_freetype=true extra_ldflags = [ \"-L/usr/local/lib\" ] cc=\"clang\" cxx=\"clang++\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\", \"-I/usr/local/include/freetype2\", \"-I/usr/local/include\"]"`    
 - `ninja -C out/llvm.arm64.release`
3. 编译skia静态库（llvm.x64.Release）
 - `gn gen out/llvm.x64.release --args="target_cpu=\"x64\" ar=\"llvm-ar\" skia_enable_fontmgr_fontconfig=true skia_use_freetype=true extra_ldflags = [ \"-L/usr/local/lib\" ] cc=\"clang\" cxx=\"clang++\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\", \"-I/usr/local/include/freetype2\", \"-I/usr/local/include\"]"`    
 - `ninja -C out/llvm.x64.release`

## 四、资源链接
1. Skia的编译文档库，如需获取最新版本的文档，请点击访问：[skia_compile](https://github.com/rhett-lee/skia_compile)     
2. nim_duilib界面库的代码库，请点击访问：[nim_duilib](https://github.com/rhett-lee/nim_duilib)     
nim_duilib 是一款基于C++开发的跨平台界面库，源于经典的 duilib 界面库并进行了深度优化与功能扩展，支持Windows/Linux/macOS/FreeBSD平台，支持的Linux系统包括OpenEuler、OpenKylin、UbuntuKylin、统信UOS、中科方德、Ubuntu、Fedora、Debian等，专注于简化桌面应用的高效开发。其设计融合了DirectUI理念，通过XML描述界面布局，实现视觉与逻辑的分离，显著提升开发灵活性与维护性。

