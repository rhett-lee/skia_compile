#!/bin/bash

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

if ! command -v ninja &> /dev/null
then
    echo "- ninja not found!"
    exit 1
else
    echo "ninja found at:"
    which ninja
fi

if ! command -v wget &> /dev/null
then
    echo "- wget not found!"
    exit 1
else
    echo "wget found at:"
    which wget
fi

if ! command -v cmake &> /dev/null
then
    echo "- cmake not found!"
    exit 1
else
    echo "cmake found at:"
    which cmake
fi

# flag
has_gcc=0

# gcc/g++
if command -v gcc &> /dev/null && command -v g++ &> /dev/null; then
    has_gcc=1
fi

if [ "$has_gcc" == "0" ]; then
    echo "- GCC/G++ not found in PATH"
    exit 1
fi

if ! command -v make &> /dev/null
then
    echo "- make not found!"
    exit 1
else
    echo "make found at:"
    which make
fi

start_time=$(date +%s)
CPU_COUNT=$(grep -c '^processor' /proc/cpuinfo)

# cpu count
if [ "$CPU_COUNT" -gt 0 ]; then
    echo "CPU_COUNT: $CPU_COUNT"
else
    CPU_COUNT=4
fi


# Function to download file with unlimited retries
# Parameters:
#   $1 - URL to download
#   $2 - Target directory to save the file
download_with_retry() {
    local url="$1"
    local download_dir="$2"
    local retry_interval=10
    
    # Create directory if not exists
    mkdir -p "$download_dir"
    
    while true; do
        echo "Attempting to download $url"
        
        # Download using wget with  directory specification
        if wget -c -P "$download_dir" "$url"; then
            echo "Download successful"
            return 0
        else
            echo "Download failed, retrying in ${retry_interval} seconds..."
            sleep $retry_interval
        fi
    done
}

# Function to download files(git clone)
# Parameters:
#   $1 - URL to download
#   $2 - Target directory to save the files
sync_git_repo() {
    local url="$1"
    local local_dir="$2"
    
    while true; do
        if [ -d "$local_dir/.git" ]; then
            echo "Directory exists, pulling latest changes..."
            if git -C "$local_dir" pull; then
                echo "Pull successful"
                return 0
            else
                # echo "Pull failed, retrying in 10 seconds..."
                sleep 10
            fi
        else
            echo "Directory doesn't exist, cloning repository..."
            if git clone "$url" "$local_dir"; then
                echo "Clone successful"
                return 0
            else
                # echo "Clone failed, retrying in 10 seconds..."
                sleep 10
            fi
        fi
    done
    
    return 1
}

# current dir 
CURRENT_DIR=$(readlink -f .)

# source code dir
SRC_DIR_NAME=src

# install dir
INSTALL_DIR_NAME=install

# binutils
binutils_src_file_name="binutils-2.44"
download_with_retry "https://ftp.gnu.org/gnu/binutils/${binutils_src_file_name}.tar.xz" "./$SRC_DIR_NAME/"

# python3
python3_src_file_name="Python-3.13.0"
download_with_retry "https://www.python.org/ftp/python/3.13.0/${python3_src_file_name}.tar.xz" "./$SRC_DIR_NAME/"

# gcc/g++
gcc_version="15.1.0"
gcc_src_file_name="gcc-15.1.0"
download_with_retry "https://ftp.gnu.org/gnu/gcc/gcc-15.1.0/${gcc_src_file_name}.tar.xz" "./$SRC_DIR_NAME/"

# llvm(clang/clang++)
llvm_src_local_dir="llvm-project-llvmorg-20.1.5"
llvm_src_file_name="llvmorg-20.1.5"
llvm_install_dir_name="llvm-20.1.5"
if [ ! -f "./$SRC_DIR_NAME/${llvm_src_file_name}.tar.gz" ]; then
    download_with_retry "https://github.com/llvm/llvm-project/archive/refs/tags/${llvm_src_file_name}.tar.gz" "./$SRC_DIR_NAME/"
fi

# gn
gn_src_file_name="gn"
if [ ! -d "./$SRC_DIR_NAME/$gn_src_file_name/.git" ]; then
    sync_git_repo "https://github.com/timniederhausen/gn.git" "./$SRC_DIR_NAME/${gn_src_file_name}"
fi

has_download_error=0
if [ ! -f "./$SRC_DIR_NAME/${binutils_src_file_name}.tar.xz" ]; then
    echo "Download file failed:" ${binutils_src_file_name}.tar.xz "!!!"
    has_download_error=1
fi

if [ ! -f "./$SRC_DIR_NAME/${gcc_src_file_name}.tar.xz" ]; then
    echo "Download file failed:" ${gcc_src_file_name}.tar.xz "!!!"
    has_download_error=1
fi

if [ ! -f "./$SRC_DIR_NAME/${llvm_src_file_name}.tar.gz" ]; then
    echo "Download file failed:" ${llvm_src_file_name}.tar.gz "!!!"
    has_download_error=1
fi

if [ ! -d "./$SRC_DIR_NAME/$gn_src_file_name/.git" ]; then
    echo "git clone source code failed:" ${gn_src_file_name} "!!!"
    has_download_error=1
fi

if [ "$has_download_error" == "1" ]; then
    exit 1
fi

# binutils compile an install
cd "${CURRENT_DIR}/$SRC_DIR_NAME/"
tar -xJf "${binutils_src_file_name}.tar.xz"
mkdir -p "${binutils_src_file_name}.build"
cd "${binutils_src_file_name}.build"
../${binutils_src_file_name}/configure --prefix="${CURRENT_DIR}/${INSTALL_DIR_NAME}/${binutils_src_file_name}/" --disable-werror --enable-gprofng=no
make -j $CPU_COUNT
make install

# gcc compile an install
cd "${CURRENT_DIR}/$SRC_DIR_NAME/"
tar -xJf "${gcc_src_file_name}.tar.xz"
cd "${gcc_src_file_name}"
./contrib/download_prerequisites
if [ $? -ne 0 ]; then
    echo "./contrib/download_prerequisites failed!"
    exit 1
fi

cd "${CURRENT_DIR}/$SRC_DIR_NAME/"
mkdir -p "${gcc_src_file_name}.build"
cd "${gcc_src_file_name}.build"
export LD="${CURRENT_DIR}/${INSTALL_DIR_NAME}/${binutils_src_file_name}/bin/ld"
../${gcc_src_file_name}/configure --prefix="${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gcc_src_file_name}/" --disable-multilib --enable-ld --enable-bootstrap
make -j $CPU_COUNT
make install

# write source.sh
SOURCE_FILE=${CURRENT_DIR}/source.sh
echo '#!/bin/bash'  >> "$SOURCE_FILE"
echo ""             >> "$SOURCE_FILE"

echo "# binutils"   >> "$SOURCE_FILE"
TEMP_LINE="export PATH=${CURRENT_DIR}/${INSTALL_DIR_NAME}/${binutils_src_file_name}/bin:"
echo -n "$TEMP_LINE">> "$SOURCE_FILE"
echo '$PATH'        >> "$SOURCE_FILE"
echo ""             >> "$SOURCE_FILE"

echo "# gcc/g++"    >> "$SOURCE_FILE"
TEMP_LINE="export PATH=${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gcc_src_file_name}/bin:"
echo -n "$TEMP_LINE">> "$SOURCE_FILE"
echo '$PATH'        >> "$SOURCE_FILE"

TEMP_LINE="export LD_LIBRARY_PATH=${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gcc_src_file_name}/lib64/:"
echo -n "$TEMP_LINE">> "$SOURCE_FILE"
echo '$LD_LIBRARY_PATH' >> "$SOURCE_FILE"

TEMP_LINE="export C_INCLUDE_PATH=${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gcc_src_file_name}/include/c++/${gcc_version}/:${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gcc_src_file_name}/include/c++/${gcc_version}/x86_64-pc-linux-gnu/:"
echo -n "$TEMP_LINE">> "$SOURCE_FILE"
echo '$C_INCLUDE_PATH' >> "$SOURCE_FILE"

TEMP_LINE="export CPLUS_INCLUDE_PATH=${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gcc_src_file_name}/include/c++/${gcc_version}/:${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gcc_src_file_name}/include/c++/${gcc_version}/x86_64-pc-linux-gnu/:"
echo -n "$TEMP_LINE">> "$SOURCE_FILE"
echo '$CPLUS_INCLUDE_PATH' >> "$SOURCE_FILE"
echo ""             >> "$SOURCE_FILE"

# source
source "$SOURCE_FILE"

# python3 compile an install
cd "${CURRENT_DIR}/$SRC_DIR_NAME/"
tar -xJf "${python3_src_file_name}.tar.xz"
mkdir -p "${python3_src_file_name}.build"
cd "${python3_src_file_name}.build"
../${python3_src_file_name}/configure --prefix="${CURRENT_DIR}/${INSTALL_DIR_NAME}/${python3_src_file_name}/"
make -j $CPU_COUNT
make install

# write source.sh
echo "# python3 "   >> "$SOURCE_FILE"
TEMP_LINE="export PATH=${CURRENT_DIR}/${INSTALL_DIR_NAME}/${python3_src_file_name}/bin:"
echo -n "$TEMP_LINE">> "$SOURCE_FILE"
echo '$PATH'        >> "$SOURCE_FILE"
echo ""             >> "$SOURCE_FILE"

# source
source "$SOURCE_FILE"

# gn compile an install
cd "${CURRENT_DIR}/$SRC_DIR_NAME/"
cd "${gn_src_file_name}"
export CXX=g++; python3 build/gen.py
ninja -C out
cd "${CURRENT_DIR}/$SRC_DIR_NAME/"
#install gn
mkdir -p "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gn_src_file_name}/bin/"
cp "${gn_src_file_name}/out/gn" "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gn_src_file_name}/bin/"

cd "${CURRENT_DIR}/"

# write source.sh
echo "# gn "   >> "$SOURCE_FILE"
TEMP_LINE="export PATH=${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gn_src_file_name}/bin:"
echo -n "$TEMP_LINE">> "$SOURCE_FILE"
echo '$PATH'        >> "$SOURCE_FILE"
echo ""             >> "$SOURCE_FILE"

# source
source "$SOURCE_FILE"

# llvm/clang/clang++ compile an install
cd "${CURRENT_DIR}/$SRC_DIR_NAME/"
tar -xzf "${llvm_src_file_name}.tar.gz"
mkdir -p "${llvm_src_local_dir}.build"

cmake -S "./${llvm_src_local_dir}/llvm/" -B "./${llvm_src_local_dir}.build" \
      -G Ninja \
      -DLLVM_ENABLE_PROJECTS="clang;lld" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_C_COMPILER="${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gcc_src_file_name}/bin/gcc" \
      -DCMAKE_CXX_COMPILER="${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gcc_src_file_name}/bin/g++" \
      -DCMAKE_INSTALL_PREFIX="${CURRENT_DIR}/${INSTALL_DIR_NAME}/${llvm_install_dir_name}"

ninja -C "./${llvm_src_local_dir}.build"
ninja -C "./${llvm_src_local_dir}.build" install

# write source.sh
echo "# llvm/clang/clang++"    >> "$SOURCE_FILE"
TEMP_LINE="export PATH=${CURRENT_DIR}/${INSTALL_DIR_NAME}/${llvm_install_dir_name}/bin:"
echo -n "$TEMP_LINE">> "$SOURCE_FILE"
echo '$PATH'        >> "$SOURCE_FILE"

TEMP_LINE="export LD_LIBRARY_PATH=${CURRENT_DIR}/${INSTALL_DIR_NAME}/${llvm_install_dir_name}/lib/:"
echo -n "$TEMP_LINE">> "$SOURCE_FILE"
echo '$LD_LIBRARY_PATH' >> "$SOURCE_FILE"

TEMP_LINE="export C_INCLUDE_PATH=${CURRENT_DIR}/${INSTALL_DIR_NAME}/${llvm_install_dir_name}/include:"
echo -n "$TEMP_LINE">> "$SOURCE_FILE"
echo '$C_INCLUDE_PATH' >> "$SOURCE_FILE"

TEMP_LINE="export CPLUS_INCLUDE_PATH=${CURRENT_DIR}/${INSTALL_DIR_NAME}/${llvm_install_dir_name}/include:"
echo -n "$TEMP_LINE">> "$SOURCE_FILE"
echo '$CPLUS_INCLUDE_PATH' >> "$SOURCE_FILE"
echo ""             >> "$SOURCE_FILE"

# source
source "$SOURCE_FILE"

if [ ! -f "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gn_src_file_name}/bin/gn" ]; then
    echo "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gn_src_file_name}/bin/gn " -- Installation failed!!!
else
    echo "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gn_src_file_name}/bin/gn " Successfully installed.
fi

if [ ! -f "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${llvm_install_dir_name}/bin/clang" ]; then
    echo "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${llvm_install_dir_name}/bin/clang " -- Installation failed!!!
else
    echo "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${llvm_install_dir_name}/bin/clang " Successfully installed.
fi

if [ ! -f "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${llvm_install_dir_name}/bin/clang++" ]; then
    echo "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${llvm_install_dir_name}/bin/clang++ " -- Installation failed!!!
else
    echo "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${llvm_install_dir_name}/bin/clang++ " Successfully installed.
fi

if [ ! -f "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${llvm_install_dir_name}/bin/clang" ]; then
    echo "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${llvm_install_dir_name}/bin/clang " -- Installation failed!!!
else
    echo "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${llvm_install_dir_name}/bin/clang " Successfully installed.
fi

if [ ! -f "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gcc_src_file_name}/bin/gcc" ]; then
    echo "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gcc_src_file_name}/bin/gcc " -- Installation failed!!!
else
    echo "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gcc_src_file_name}/bin/gcc " Successfully installed.
fi

if [ ! -f "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gcc_src_file_name}/bin/g++" ]; then
    echo "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gcc_src_file_name}/bin/g++ " -- Installation failed!!!
else
    echo "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${gcc_src_file_name}/bin/g++ " Successfully installed.
fi

if [ ! -f "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${binutils_src_file_name}/bin/ld" ]; then
    echo "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${binutils_src_file_name}/bin/ld " -- Installation failed!!!
else
    echo "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${binutils_src_file_name}/bin/ld " Successfully installed.
fi

if [ ! -f "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${binutils_src_file_name}/bin/ar" ]; then
    echo "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${binutils_src_file_name}/bin/ar " -- Installation failed!!!
else
    echo "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${binutils_src_file_name}/bin/ar " Successfully installed.
fi

if [ ! -f "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${python3_src_file_name}/bin/python3" ]; then
    echo "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${python3_src_file_name}/bin/python3 " -- Installation failed!!!
else
    echo "${CURRENT_DIR}/${INSTALL_DIR_NAME}/${python3_src_file_name}/bin/python3 " Successfully installed.
fi

echo
which python3
which clang
which clang++
which gcc
which gcc++
which gn
which ar
which ld

echo

end_time=$(date +%s)
duration=$((end_time - start_time))
if (( duration >= 60 )); then
    minutes=$((duration / 60))
    echo "Execution completed in $minutes minute(s)"
else
    echo "Execution completed in $duration second(s)"
fi
