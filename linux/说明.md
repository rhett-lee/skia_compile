## 编译Skia的脚本（一键完成）
选定一个工作目录，创建一个脚本`build.sh`，将下面已经整理好脚本复制进去，保存文件。    
然后在控制台，为脚本文件添加可执行权限，最后运行该脚本： 
```
chmod +x build.sh
./build.sh
```

脚本文件内容如下：    
```
#!/bin/bash

git clone https://github.com/rhett-lee/skia_compile
chmod +x ./skia_compile/linux/build_skia_all_in_one.sh
./skia_compile/linux/build_skia_all_in_one.sh
```
编译时如果获取skia_compile代码失败，可以多重试几次。    
编译完成的库文件在工作目录的`skia/out`子目录中，按编译选项放在相应的子目录。  
