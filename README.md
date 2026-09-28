# skia_compile

[skia_compile](https://github.com/rhett-lee/skia_compile) 是介绍各个平台下如何编译skia的文档库。该库中介绍的编译Skia源码的方法，是为了适配[nim_duilib](https://github.com/rhett-lee/nim_duilib)项目使用Skia库，如果用于其他库使用，可能需要修改编译参数。

![GitHub](https://img.shields.io/badge/license-MIT-green.svg)

## 文档列表
| 文档名称                  | 操作系统 | 编译器      |内容简介 |
| :---                      | :---     | :---        | :---    |
| [compile_skia_on_windows.md](compile_skia_on_windows.md) | Windows  | LLVM+VS2022/VS2026<br>LLVM+VS2017/VS2019 |Windows系统中使用LLVM或Visual Studio 2022/2026编译Skia源码的方法（主分支）<br> 如果使用VS2017/VS2019，请使用develop-cpp17分支，主分支不支持VS2017/VS2019|
| [compile_skia_on_windows_mingw64.md](compile_skia_on_windows_mingw64.md)                | Windows  | MinGW-W64(gcc/g++或LLVM) |Windows系统中使用MinGW-W64(gcc/g++或LLVM)编译Skia源码的方法|
| [compile_skia_on_openeuler.md](compile_skia_on_openeuler.md) | OpenEuler  | LLVM/gcc |OpenEuler系统中使用LLVM或者gcc编译Skia源码的方法|
| [compile_skia_on_ubuntu.md](compile_skia_on_ubuntu.md) | Ubuntu  | LLVM/gcc |Ubuntu系统中使用LLVM或者gcc编译Skia源码的方法|
| [compile_skia_on_debian.md](compile_skia_on_debian.md) | Debian  | LLVM/gcc |Debian系统中使用LLVM或者gcc编译Skia源码的方法|
| [compile_skia_on_fedora.md](compile_skia_on_fedora.md) | Fedora  | LLVM/gcc |Fedora系统中使用LLVM或者gcc编译Skia源码的方法|
| [compile_skia_on_uos.md](compile_skia_on_uos.md) | UOS  | LLVM/gcc |统信UOS系统中使用LLVM或者gcc编译Skia源码的方法|
| [compile_skia_on_neokylin.md](compile_skia_on_neokylin.md) | 中科方德  | LLVM/gcc |中科方德系统中使用LLVM或者gcc编译Skia源码的方法|
| [compile_skia_on_ubuntukylin.md](compile_skia_on_ubuntukylin.md) | UbuntuKylin  | LLVM/gcc |UbuntuKylin系统中使用LLVM或者gcc编译Skia源码的方法|
| [compile_skia_on_openkylin.md](compile_skia_on_openkylin.md) | OpenKylin  | LLVM/gcc |OpenKylin系统中使用LLVM或者gcc编译Skia源码的方法|
| [compile_skia_on_opensuse.md](compile_skia_on_opensuse.md) | OpenSuse  | LLVM/gcc |OpenSuse系统中使用LLVM或者gcc编译Skia源码的方法|
| [compile_skia_on_macos.md](compile_skia_on_macos.md) | macOS  | clang/clang++ |macOS系统中使用clang/clang++编译Skia源码的方法|
| [compile_skia_on_freebsd.md](compile_skia_on_freebsd.md) | FreeBSD  | clang/clang++ |FreeBSD系统中使用clang/clang++编译Skia源码的方法|

## 资源链接
1. nim_duilib界面库，点击访问：[nim_duilib](https://github.com/rhett-lee/nim_duilib) 
2. Skia的编译文档库，点击访问：[skia_compile](https://github.com/rhett-lee/skia_compile) 
