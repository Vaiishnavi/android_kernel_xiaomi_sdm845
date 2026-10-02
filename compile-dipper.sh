#!/bin/sh

# Many parts of this script were taken from @REIGNZ, @idkwhoiam322 and @raphielscape . Huge thanks to them.

# KernelSu
# curl -LSs "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/main/kernel/setup.sh" | bash -s builtin

# Cleaning
#rm -rf out
#make clean
#make mrproper

# Some general variables
PHONE="dipper"
ARCH="arm64"
SUBARCH="arm64"
COMPILER=clang
LINKER=""
COMPILERDIR="$(pwd)/clang"

# Outputs
mkdir -p zone_dipper
mkdir -p out

# Export shits
export KBUILD_BUILD_USER=Zone
export KBUILD_BUILD_HOST=D543

# Speed up build process
MAKE="./makeparallel"

# Basic build function
BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

Build () {
PATH="${COMPILERDIR}/bin:${PATH}" \
make -j$(nproc --all) O=out vendor/xiaomi/mi845_defconfig vendor/xiaomi/dipper.config \
ARCH=${ARCH} \
LLVM=1 LLVM_IAS=1 \
CC=${COMPILER} \
CROSS_COMPILE=${COMPILERDIR}/bin/aarch64-linux-gnu- \
CROSS_COMPILE_ARM32=${COMPILERDIR}/bin/arm-linux-gnueabi- \
LD=ld.lld \
HOSTCC=clang \
HOSTLDFLAGS="-fuse-ld=lld" \
AR=llvm-ar \
NM=llvm-nm \
OBJCOPY=llvm-objcopy \
OBJDUMP=llvm-objdump \
STRIP=llvm-strip \
LD_LIBRARY_PATH=${COMPILERDIR}/lib 2>&1 | tee log.txt
}

# Build starts here
    #NSE
    Build
    if [ $? -ne 0 ]
    then
        echo "Build failed"
        rm -rf out/*
    else
        echo "Build succesful"
    fi

#Anykernel 
if [ ! -d "AnyKernel3" ]; then
            git clone -q https://github.com/diyantika/AnyKernel3.git -b Dipper-SE AnyKernel3
        fi
        
Zipping () {
       ZIPNAME="${PHONE}.zip"
       cd AnyKernel3
        git checkout Dipper-SE &> /dev/null
        zip -r9 "../$ZIPNAME" * -x .git README.md *placeholder
        cd ..
        #Pindah Zip
        mv "$ZIPNAME" zone_dipper/
       }

#NSE
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel3/
Zipping "NSE"

rm -rf AnyKernel3/

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
