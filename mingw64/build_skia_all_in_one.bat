echo OFF

:: Checking the necessary software
where git.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo git.exe found at:  
    where git.exe
) else (
    echo - git.exe not found in PATH
    exit /b 1
)

where python3.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo python3.exe found at:  
    where python3.exe
) else (
    echo - python3.exe not found in PATH
    exit /b 1
)

:: flag
set has_gcc=0
set has_clang=0

:: gcc/g++
where gcc >nul 2>&1 && where g++ >nul 2>&1 && set has_gcc=1

:: clang/clang++
where clang >nul 2>&1 && where clang++ >nul 2>&1 && set has_clang=1

if %has_gcc%%has_clang% equ 00 (
    echo  - GCC/G++£¨MinGW£©not found in PATH
    echo  - Clang/Clang++£¨LLVM£©not found in PATH
    exit /b 1
)

set retry_delay=10
:retry_clone_skia
if not exist ".\skia" (
    git clone https://github.com/google/skia.git
) else (
    git -C ./skia stash
    git -C ./skia checkout main
    git -C ./skia pull
)
if %errorlevel% neq 0 (
    timeout /t %retry_delay% >nul
    goto retry_clone_skia
)

if not exist ".\skia" (
    echo clone skia failed!
    exit /b 1
)

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

if not exist ".\skia_compile" (
    echo clone retry_clone_skia_compile failed!
    exit /b 1
)

set SKIA_PATCH_SRC_ZIP=skia.2025-06-06.src.zip
if not exist ".\skia_compile\%SKIA_PATCH_SRC_ZIP%" (
    echo ".\skia_compile\%SKIA_PATCH_SRC_ZIP%" not found!
    exit /b 1
)

cd skia
git checkout 290495056ba5b737330ae7f2e6e722eeda9526f8
if %errorlevel% neq 0 (
    echo git checkout skia failed!
    exit /b 1
)
cd ..

.\skia_compile\windows\bin\miniunz.exe -o skia_compile/%SKIA_PATCH_SRC_ZIP% -d ./skia/
if %errorlevel% neq 0 (
    echo ".\skia_compile\%SKIA_PATCH_SRC_ZIP%" Expand-Archive failed!
    exit /b 1
)

if "%has_clang%"=="1" (
:: clang/clang++
    echo clang++ found at:  
    where clang++

    echo clang found at:  
    where clang
    
    cd .\skia
    .\bin\gn.exe gen out/mingw64-llvm.x64.release --args="target_cpu=\"x64\" cc=\"clang\" cxx=\"clang++\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\"]"
    .\bin\ninja.exe -C out/mingw64-llvm.x64.release

    .\bin\gn.exe gen out/mingw64-llvm.x86.release --args="target_cpu=\"x86\" cc=\"clang\" cxx=\"clang++\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\"]"
    .\bin\ninja.exe -C out/mingw64-llvm.x86.release
    cd ..
) else if "%has_gcc%"=="1" (
:: gcc/g++
    echo g++ found at:  
    where g++

    echo gcc found at:  
    where gcc
    
    cd .\skia
    .\bin\gn.exe gen out/mingw64-gcc.x64.release --args="target_cpu=\"x64\" cc=\"gcc\" cxx=\"g++\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\"]"
    .\bin\ninja.exe -C out/mingw64-gcc.x64.release

    .\bin\gn.exe gen out/mingw64-gcc.x86.release --args="target_cpu=\"x86\" cc=\"gcc\" cxx=\"g++\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\"]"
    .\bin\ninja.exe -C out/mingw64-gcc.x86.release
    cd ..
)

echo.
echo finished.
