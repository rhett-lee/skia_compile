#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd "$SCRIPT_DIR"

CPU_ARCH_STR=$(uname -m)
if [ "$CPU_ARCH_STR" = "x86_64" ] || [ "$CPU_ARCH_STR" = "amd64" ]; then
    CPU_ARCH=x64
elif [ "$CPU_ARCH_STR" = "aarch64" ] || [ "$CPU_ARCH_STR" = "arm64" ]; then
    CPU_ARCH=arm64
elif [ "$CPU_ARCH_STR" = "armv7l" ]; then
    CPU_ARCH=arm
elif [ "$CPU_ARCH_STR" = "i386" ] || [ "$CPU_ARCH_STR" = "i686" ]; then
    CPU_ARCH=x86
else
    CPU_ARCH=x64
fi

# Checking the necessary software
if ! command -v git &> /dev/null
then
    echo "- git not found!"
    exit 1
else
    echo "git found at:"
    which git
fi

if ! command -v python3 &> /dev/null
then
    echo "- python3 not found!"
    exit 1
else
    echo "python3 found at:"
    which python3
fi

if ! command -v gn &> /dev/null
then
    echo "- gn not found!"
    exit 1
else
    echo "gn found at:"
    which gn
fi

if ! command -v ninja &> /dev/null
then
    echo "- ninja not found!"
    exit 1
else
    echo "ninja found at:"
    which ninja
fi

if ! command -v unzip &> /dev/null
then
    echo "- unzip not found!"
    exit 1
else
    echo "unzip found at:"
    which unzip
fi

# flag
has_gcc=0
has_clang=0

# gcc/g++
if command -v gcc &> /dev/null && command -v g++ &> /dev/null; then
    has_gcc=1
fi

# clang/clang++
if command -v clang &> /dev/null && command -v clang++ &> /dev/null; then
    has_clang=1
fi

if [ "$has_gcc$has_clang" == "00" ]; then
    echo "- GCC/G++ not found in PATH"
    echo "- Clang/Clang++ not found in PATH"
    exit 1
fi

if [ ! -d "./skia_compile/.git" ]; then
    if [ -d "../../skia_compile/.git" ]; then
        cd ../../
    fi
fi

pwd

start_time=$(date +%s)
retry_delay=10

# Retry clone skia
clone_skia() {
    if [ ! -d "./skia/.git" ]; then
        git clone https://github.com/google/skia.git
    else
        git -C ./skia stash
        git -C ./skia checkout main
        git -C ./skia pull
    fi
    if [ $? -ne 0 ]; then
        sleep $retry_delay
        clone_skia
    fi
}
clone_skia
if [ ! -d "./skia/.git" ]; then
    echo "clone skia failed!"
    exit 1
fi

# Retry clone skia_compile
clone_skia_compile() {
    if [ ! -d "./skia_compile/.git" ]; then
        git clone https://github.com/rhett-lee/skia_compile.git
    else
        git -C ./skia_compile pull
    fi
    if [ $? -ne 0 ]; then
        sleep $retry_delay
        clone_skia_compile
    fi
}
clone_skia_compile
if [ ! -d "./skia_compile/.git" ]; then
    echo "clone skia_compile failed!"
    exit 1
fi

SKIA_PATCH_SRC_ZIP=skia.2025-06-06.src.zip
if [ ! -f "./skia_compile/$SKIA_PATCH_SRC_ZIP" ]; then
    echo "./skia_compile/$SKIA_PATCH_SRC_ZIP not found!"
    exit 1
fi

cd skia
git checkout 290495056ba5b737330ae7f2e6e722eeda9526f8
if [ $? -ne 0 ]; then
    echo "git checkout skia failed!"
    exit 1
fi
cd ..

unzip -o skia_compile/$SKIA_PATCH_SRC_ZIP -d ./skia/
if [ $? -ne 0 ]; then
    echo "./skia_compile/$SKIA_PATCH_SRC_ZIP unzip failed!"
    exit 1
fi

if [ "$has_clang" -eq 1 ]; then
    # clang/clang++
    echo "clang++ found at:"
    which clang++

    echo "clang found at:"
    which clang

    cd ./skia
    gn gen out/llvm.${CPU_ARCH}.release --args="target_cpu=\"${CPU_ARCH}\" cc=\"clang\" cxx=\"clang++\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\"]"
    ninja -C out/llvm.${CPU_ARCH}.release
    cd ..
else
    if [ "$has_gcc" -eq 1 ]; then
        # gcc/g++
        echo "g++ found at:"
        which g++

        echo "gcc found at:"
        which gcc

        cd ./skia
        gn gen out/gcc.${CPU_ARCH}.release --args="target_cpu=\"${CPU_ARCH}\" cc=\"gcc\" cxx=\"g++\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\"]"
        ninja -C out/gcc.${CPU_ARCH}.release
        cd ..
    fi
fi

cd "$SCRIPT_DIR"
echo

end_time=$(date +%s)
duration=$((end_time - start_time))
if (( duration >= 60 )); then
    minutes=$((duration / 60))
    echo "Execution completed in $minutes minute(s)"
else
    echo "Execution completed in $duration second(s)"
fi
