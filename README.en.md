English | [简体中文](README.md)

# skia_compile

[skia\_compile](https://github.com/rhett-lee/skia_compile) is a documentation repository that explains how to build Skia from source on various platforms. The build methods described here are intended to support the [nim\_duilib](https://github.com/rhett-lee/nim_duilib) project's use of the Skia library; if you use them with other libraries, you may need to adjust the build arguments.

![GitHub](https://img.shields.io/badge/license-MIT-green.svg)

> Note: English versions of all per-platform documents are now available. Some subdirectory documents are still being translated.

## Document List

| Document                                                     | OS          | Compiler                                       | Description                                                                                                                                                                                      |
| :----------------------------------------------------------- | :---------- | :--------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Windows (LLVM)](compile_skia_on_windows.en.md)              | Windows     | LLVM + VS2022/VS2026<br />LLVM + VS2017/VS2019 | How to build Skia from source on Windows using LLVM or Visual Studio 2022/2026 (main branch). For VS2017/VS2019, use the `develop-cpp17` branch; the main branch does not support VS2017/VS2019. |
| [Windows (MinGW-W64)](compile_skia_on_windows_mingw64.en.md) | Windows     | MinGW-W64 (gcc/g++ or LLVM)                    | How to build Skia from source on Windows using MinGW-W64 (gcc/g++ or LLVM-MinGW).                                                                                                                |
| [OpenEuler](compile_skia_on_openeuler.en.md)                    | OpenEuler   | LLVM/gcc                                       | How to build Skia on OpenEuler using LLVM or gcc.                                                                                                                                                |
| [Ubuntu](compile_skia_on_ubuntu.en.md)                          | Ubuntu      | LLVM/gcc                                       | How to build Skia on Ubuntu using LLVM or gcc.                                                                                                                                                   |
| [Debian](compile_skia_on_debian.en.md)                          | Debian      | LLVM/gcc                                       | How to build Skia on Debian using LLVM or gcc.                                                                                                                                                   |
| [Fedora](compile_skia_on_fedora.en.md)                          | Fedora      | LLVM/gcc                                       | How to build Skia on Fedora using LLVM or gcc.                                                                                                                                                   |
| [UOS](compile_skia_on_uos.en.md)                                | UOS         | LLVM/gcc                                       | How to build Skia on UOS (UnionTech OS) using LLVM or gcc.                                                                                                                                       |
| [NeoKylin](compile_skia_on_neokylin.en.md)                      | NeoKylin    | LLVM/gcc                                       | How to build Skia on NeoKylin using LLVM or gcc.                                                                                                                                                 |
| [UbuntuKylin](compile_skia_on_ubuntukylin.en.md)                | UbuntuKylin | LLVM/gcc                                       | How to build Skia on UbuntuKylin using LLVM or gcc.                                                                                                                                              |
| [OpenKylin](compile_skia_on_openkylin.en.md)                    | OpenKylin   | LLVM/gcc                                       | How to build Skia on OpenKylin using LLVM or gcc.                                                                                                                                                |
| [OpenSuse](compile_skia_on_opensuse.en.md)                      | OpenSuse    | LLVM/gcc                                       | How to build Skia on OpenSuse using LLVM or gcc.                                                                                                                                                 |
| [macOS](compile_skia_on_macos.en.md)                            | macOS       | clang/clang++                                  | How to build Skia on macOS using clang/clang++.                                                                                                                                                  |
| [FreeBSD](compile_skia_on_freebsd.en.md)                        | FreeBSD     | clang/clang++                                  | How to build Skia on FreeBSD using clang/clang++.                                                                                                                                                |

## Resource Links

1. nim_duilib GUI library — visit: [nim\_duilib](https://github.com/rhett-lee/nim_duilib)
2. Skia build documentation repository — visit: [skia\_compile](https://github.com/rhett-lee/skia_compile)
