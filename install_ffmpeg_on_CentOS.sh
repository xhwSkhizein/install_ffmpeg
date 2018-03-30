#!/bin/sh
# 参考 [[https://trac.ffmpeg.org/wiki/CompilationGuide/Centos]]
# 
# TODO: 环境检查, 跳过已安装, 支持不同版本安装, 不同Linux系统兼容, 硬编码问题, 终端颜色, 自动关联最后ffmpeg configure参数

Green='\033[0;32m'
Red='\033[0;31m' 
ColorReset='\033[0m'

greenNotice(){
    echo "$Green $1 $ColorReset"
}
failWarning(){
    echo "$Red $1 $ColorReset"
}

# 命令执行失败重试
retryWhenFail(){
    n=0
    until [ $n -ge 5 ]
    do
        echo $1 && break  # substitute your command here
        n=$[$n+1]
        echo "$1 执行失败，是否重试？[y/n]"
        read input
        if [ $input = 'n' ] ; then
            break
        fi
        sleep 15
    done
}

# 检查参数是否提供工作目录
if [ $# -lt 1 ] ; then
    failWarning "\n $Red Usage: $0 [path_for_download_file] $ColorReset \n";
    exit 1;
fi

export WORK_DIR=$1

retryWhenFail `mkdir -p $WORK_DIR`

greenNotice "安装依赖..."

retryWhenFail `yum install autoconf automake bzip2 cmake freetype-devel gcc gcc-c++ git libtool make mercurial pkgconfig zlib-devel`


# echo "\n"
# greenNotice "\n Install NASM-2.13.02 ? [y/n]"
# read input
# if [ $input = 'y' ] ; then
#     cd $WORK_DIR
#     (ls nasm-2.13.02.tar.bz2 >> /dev/null 2>&1) || curl -O -L http://www.nasm.us/pub/nasm/releasebuilds/2.13.02/nasm-2.13.02.tar.bz2
#     tar xjvf nasm-2.13.02.tar.bz2
#     cd $WORK_DIR/nasm-2.13.02
#     yum remove nasm && hash -r # 系统自带的nasm(版本过低)
#     ./autogen.sh
#     ./configure --prefix="$WORK_DIR/ffmpeg_build" --bindir="$WORK_DIR/bin"
#     make
#     make install
#     greenNotice "Install NASM-2.13.02, Done!"
# fi

echo "\n"
greenNotice "\nInstall Ysam-1.3.0 ? [y/n]"
read input
if [ $input = 'y' ] ; then
    cd $WORK_DIR
    (ls yasm-1.3.0.tar.gz >> /dev/null 2>&1) || curl -O -L http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
    tar xzvf yasm-1.3.0.tar.gz
    cd yasm-1.3.0
    ./configure --prefix="$WORK_DIR/ffmpeg_build" --bindir="$WORK_DIR/bin"
    make
    make install
    greenNotice "Install Ysam-1.3.0, Done!"
fi 

echo "\n"
greenNotice "\nInstall libx264 ? [y/n]"
read input
if [ $input = 'y' ] ; then
    cd $WORK_DIR
    (ls x264 >> /dev/null 2>&1) || git clone --depth 1 http://git.videolan.org/git/x264
    cd x264
    PKG_CONFIG_PATH="$WORK_DIR/ffmpeg_build/$WORK_DIR/pkgconfig" ./configure --prefix="$WORK_DIR/ffmpeg_build" --bindir="$WORK_DIR/bin" --enable-static --disable-asm
    make
    make install
    greenNotice "Install libx264, Done!"
fi

echo "\n"
greenNotice "\nInstall libx265 ? [y/n]"
read input
if [ $input = 'y' ] ; then
    cd $WORK_DIR
    (ls x265 >> /dev/null 2>&1) || hg clone https://bitbucket.org/multicoreware/x265
    cd $WORK_DIR/x265/build/linux
    cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$WORK_DIR/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source
    make
    make install
    greenNotice "Install libx265, Done!"
fi

echo "\n"
greenNotice "\nInstall libfdk_aac ? [y/n]"
read input
if [ $input = 'y' ] ; then
    cd $WORK_DIR
    (ls fdk-acc >> /dev/null 2>&1) || git clone --depth 1 https://github.com/mstorsjo/fdk-aac
    cd fdk-aac
    autoreconf -fiv
    ./configure --prefix="$WORK_DIR/ffmpeg_build" --disable-shared
    make
    make install
    greenNotice "Install libfdk_aac, Done!"
fi

echo "\n"
greenNotice "\nInstall libmp3lame ? [y/n]"
read input
if [ $input = 'y' ] ; then
    cd $WORK_DIR
    (ls lame-3.100.tar.gz >> /dev/null 2>&1) || curl -O -L http://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz
    tar xzvf lame-3.100.tar.gz
    cd lame-3.100
    ./configure --prefix="$WORK_DIR/ffmpeg_build" --bindir="$WORK_DIR/bin" --disable-shared --enable-nasm
    make
    make install
    greenNotice "Install libmp3lame, Done!"
fi  

echo "\n"
greenNotice "\nInstall libopus ? [y/n]"
read input
if [ $input = 'y' ] ; then
    cd $WORK_DIR
    (ls opus-1.2.1.tar.gz >> /dev/null 2>&1) || curl -O -L https://archive.mozilla.org/pub/opus/opus-1.2.1.tar.gz
    tar xzvf opus-1.2.1.tar.gz
    cd opus-1.2.1
    ./configure --prefix="$WORK_DIR/ffmpeg_build" --disable-shared
    make
    make install
    greenNotice "Install libopus, Done!"
fi

echo "\n"
greenNotice "\nInstall libogg ? [y/n]"
read input
if [ $input = 'y' ] ; then
    cd $WORK_DIR
    (ls libogg-1.3.3.tar.gz >> /dev/null 2>&1) || curl -O -L http://downloads.xiph.org/releases/ogg/libogg-1.3.3.tar.gz
    tar xzvf libogg-1.3.3.tar.gz
    cd libogg-1.3.3
    ./configure --prefix="$WORK_DIR/ffmpeg_build" --disable-shared
    make
    make install
    greenNotice "Install libogg, Done!"
fi

echo "\n"
greenNotice "\nInstall libvorbis ? [y/n]"
read input
if [ $input = 'y' ] ; then
    cd $WORK_DIR
    (ls libvorbis-1.3.5.tar.gz >> /dev/null 2>&1) || curl -O -L http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.gz
    tar xzvf libvorbis-1.3.5.tar.gz
    cd libvorbis-1.3.5
    ./configure --prefix="$WORK_DIR/ffmpeg_build" --with-ogg="$WORK_DIR/ffmpeg_build" --disable-shared
    make
    make install
    greenNotice "Install libvorbis, Done!"
fi

echo "\n"
greenNotice "\nInstall libvpx ? [y/n]"
read input
if [ $input = 'y' ] ; then
    cd $WORK_DIR
    (ls libvpx >> /dev/null 2>&1) || git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
    cd libvpx
    ./configure --prefix="$WORK_DIR/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm
    make
    make install
    greenNotice "Install libvpx, Done!"
fi

cd $WORK_DIR
greenNotice "enter $WORK_DIR, ready to install ffmpeg."

(ls ffmpeg-snapshot.tar.bz2 >> /dev/null 2>&1) || curl -O -L https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar xjvf ffmpeg-snapshot.tar.bz2
cd ffmpeg
export PATH="$WORK_DIR/bin:$PATH" PKG_CONFIG_PATH="$WORK_DIR/ffmpeg_build/lib/pkgconfig" 
./configure --prefix="/usr/local/bin/" --pkg-config-flags="--static" --extra-cflags="-I$WORK_DIR/ffmpeg_build/include" --extra-ldflags="-L$WORK_DIR/ffmpeg_build/$WORK_DIR" --extra-$WORK_DIRs=-lpthread --extra-$WORK_DIRs=-lm --bindir="$WORK_DIR/bin" --enable-gpl --enable-$WORK_DIRfdk_aac --enable-$WORK_DIRfreetype --enable-$WORK_DIRmp3lame --enable-$WORK_DIRopus --enable-$WORK_DIRvorbis --enable-$WORK_DIRvpx --enable-$WORK_DIRx264 --enable-$WORK_DIRx265 --enable-nonfree
make
make install
hash -r

