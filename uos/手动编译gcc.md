# 手动编译gcc的方法
当系统自带的gcc/g++版本较低时，不支持C++20，可以手动从源码编译最新版本的gcc/g++。
## 准备工作：安装必备的软件
安装依赖的软件:    
    `sudo apt install -y gcc g++ gdb make wget`    

## 下载源码、编译最新版的gcc/g++
（1）假设工作目录为：`~/develop`    
（2）创建源码目录：`mkdir src; cd src`    
（3）进入工作目录：`~/develop/src`    
（4）下载：`wget https://ftp.gnu.org/gnu/gcc/gcc-15.1.0/gcc-15.1.0.tar.gz`    
（5）解压：`tar -xzf gcc-15.1.0.tar.gz`    
（6）下载gcc依赖的第三方库：进入gcc-15.1.0目录，然后下载依赖的第三方库    
　　`cd ~/develop/src/gcc-15.1.0`    
　　`./contrib/download_prerequisites`    
（7）配置：    
　　`mkdir -p ~/develop/src/gcc-15.1.0.build`    
　　`cd ~/develop/src/gcc-15.1.0.build`    
　　`../gcc-15.1.0/configure --prefix=~/develop/install/gcc-15.1.0 --disable-multilib --enable-ld --enable-bootstrap`    
（8）编译：`make -j 4` 多进程编译，编译参数可参考电脑实际有几个核心。    
（9）安装：`make install`    
（10）设置环境变量，以使新版gcc/g++可用：    
　　`export PATH=~/develop/install/gcc-15.1.0/bin/:$PATH`    
　　`export LD_LIBRARY_PATH=~/develop/install/gcc-15.1.0/lib64/:$LD_LIBRARY_PATH`    
　　`export C_INCLUDE_PATH=~/develop/install/gcc-15.1.0/include/c++/15.1.0/:~/develop/install/gcc-15.1.0/include/c++/15.1.0/x86_64-pc-linux-gnu/:$C_INCLUDE_PATH`    
　　`export CPLUS_INCLUDE_PATH=~/develop/install/gcc-15.1.0/include/c++/15.1.0/:~/develop/install/gcc-15.1.0/include/c++/15.1.0/x86_64-pc-linux-gnu/:$CPLUS_INCLUDE_PATH`    


## 七、资源链接
1. Skia的编译文档库，点击访问：[skia compile](https://github.com/rhett-lee/skia_compile) 
2. nim duilib的代码库，点击访问：[nim duilib](https://github.com/rhett-lee/nim_duilib) 
