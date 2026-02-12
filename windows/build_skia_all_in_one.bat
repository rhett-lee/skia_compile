echo OFF
set OLD_DIR=%CD%
cd /d %~dp0
echo %CD%

echo Checking the necessary software
where git.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo git.exe found at:  
    where git.exe
) else (
    echo git.exe not found in PATH
    exit /b 1
)

where python3.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo python3.exe found at:  
    where python3.exe
) else (
    echo python3.exe not found in PATH
    exit /b 1
)

set LLVM_ROOT=C:\LLVM

if exist "%LLVM_ROOT%\bin\clang.exe" (
    echo clang.exe found at: %LLVM_ROOT%\bin\clang.exe
) else (
    echo clang.exe not found in default location
    exit /b 1
)

if exist "%LLVM_ROOT%\bin\clang++.exe" (
    echo clang++.exe found at: %LLVM_ROOT%\bin\clang++.exe
) else (
    echo clang++.exe not found in default location
    exit /b 1
)

if not exist ".\skia_compile\.git" (
    if exist "..\..\skia_compile\.git" (
        cd ..\..\        
    )
)

echo %CD%

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
    echo clone retry_clone_skia_compile failed!
    exit /b 1
)

:retry_clone_skia
if not exist ".\skia\.git" (
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

if not exist ".\skia\.git" (
    echo clone skia failed!
    exit /b 1
)

set SKIA_PATCH_SRC_ZIP=skia.2026-02-10.src.zip
if not exist ".\skia_compile\%SKIA_PATCH_SRC_ZIP%" (
    echo ".\skia_compile\%SKIA_PATCH_SRC_ZIP%" not found!
    exit /b 1
)

cd skia
git checkout 34aa71b8bee4648a442b7125680232d803374f19
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

cd skia
.\bin\gn.exe gen out/llvm.x64.debug --ide="vs2022" --sln="skia" --args="target_cpu=\"x64\" cc=\"clang\" cxx=\"clang++\" clang_win=\"%LLVM_ROOT%\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\",\"/MTd\"]"
.\bin\ninja.exe -C out/llvm.x64.debug

.\bin\gn.exe gen out/llvm.x64.release --ide="vs2022" --sln="skia" --args="target_cpu=\"x64\" cc=\"clang\" cxx=\"clang++\" clang_win=\"%LLVM_ROOT%\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\",\"/MT\"]"
.\bin\ninja.exe -C out/llvm.x64.release

.\bin\gn.exe gen out/llvm.x86.release --ide="vs2022" --sln="skia" --args="target_cpu=\"x86\" cc=\"clang\" cxx=\"clang++\" clang_win=\"%LLVM_ROOT%\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\",\"/MT\"]"
.\bin\ninja.exe -C out/llvm.x86.release

.\bin\gn.exe gen out/llvm.x86.debug --ide="vs2022" --sln="skia" --args="target_cpu=\"x86\" cc=\"clang\" cxx=\"clang++\" clang_win=\"%LLVM_ROOT%\" is_trivial_abi=false is_official_build=true skia_use_libwebp_encode=false skia_use_libwebp_decode=false skia_use_libpng_encode=false skia_use_libpng_decode=false skia_use_zlib=false skia_use_libjpeg_turbo_encode=false skia_use_libjpeg_turbo_decode=false skia_enable_fontmgr_win_gdi=false skia_use_icu=false skia_use_expat=false skia_use_xps=false skia_enable_pdf=false skia_use_wuffs=false skia_enable_svg=true skia_use_expat=true skia_use_system_expat=false is_debug=false extra_cflags=[\"-DSK_DISABLE_LEGACY_PNG_WRITEBUFFER\",\"/MTd\"]"
.\bin\ninja.exe -C out/llvm.x86.debug
cd ..

cd %OLD_DIR%
echo.
echo finished.
