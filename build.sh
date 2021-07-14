#!/bin/bash
    red="\033[1;31m"
    yellow="\033[1;33m"
    green="\033[1;32m"
    echo -e "$green"

  function path {
# EXPORT
    KERNEL_DIR=`pwd`
    ZIP_DIR=${HOME}/Repack
    OUT=$KERNEL_DIR/out

# COMPILER_FLAGS
    CLANG_PATH=${HOME}/proton-clang/bin
    export PATH=${CLANG_PATH}:${PATH}
    CROSS_COMPILE=aarch64-linux-gnu-
    CROSS_COMPILE_ARM32=arm-linux-gnueabi-
    CC=clang
    FLAG=-j$(nproc --all)
}
   
# MENU
    echo -e ""
    echo -e " Menu                                                                      "
    echo -e " ╔════════════════════════════════════════════════════════════════════════╗"
    echo -e " ║ 1. BERYLLIUM                                                           ║"
    echo -e " ║ e. EXIT                                                                ║"
    echo -e " ╚════════════════════════════════════════════════════════════════════════╝"
    echo -ne "\n press 1 to build , or press 'e' for back to shell : "

    read -r menu

    function compile { 
# BUILD-START  
    KERNEL_NAME=
    LC_ALL=C date +%Y-%m-%d	
    date=`date +"%Y%m%d-%H%M"`	
    BUILD_START=$(date +"%s")

# COMPILING
    rm -rf ${DEVICE}
    mkdir ${DEVICE}
    make clean mrproper
    make O=${DEVICE} clean mrproper ${KERNEL_NAME}${DEVICE}_defconfig 
    make O=${DEVICE} CC=$CC ${FLAG} \ CROSS_COMPILE=$CROSS_COMPILE \ CROSS_COMPILE_ARM32=$CROSS_COMPILE_ARM32

# BUILD-END  
    BUILD_END=$(date +"%s")	
    DIFF=$(($BUILD_END - $BUILD_START))	
    echo -e "Build completed for ${DEVICE} in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
    }
    function check {
    if [ -f $KERNEL_DIR/${DEVICE}/arch/arm64/boot/Image.gz-dtb ]
       then
       repack
       else
       echo -e "Image.gz-dtb missing!"
       echo -e "pls verify compile log"
    fi
    }    
    function repack { 
    echo -e ""
    echo -e ""
    echo -e ""      
    echo -e "Zipping now"       
# ZIP_NAME
    VERSION=
    VARIANT=
    FINAL_ZIP="${KERNEL_NAME}${DEVICE}-${VERSION}-${VARIANT}.zip"

# PACKING
    cd $ZIP_DIR
    cp $KERNEL_DIR/${DEVICE}/arch/arm64/boot/Image.gz-dtb $ZIP_DIR/
    zip -r9 "${FINAL_ZIP}" *
    cp *.zip $OUT
    rm *.zip
    cd $KERNEL_DIR
    rm $ZIP_DIR/Image.gz-dtb
    }

# DEVICE-SELECTION
    if [[ "$menu" == "1" ]]; then
    clear
    path
    DEVICE=beryllium
    echo -e "Compiling for ${DEVICE}"
    compile
    check 

    elif [[ "$menu" == "e" ]]; then
    clear
    exit
    else
    clear
    echo -e "Error!"    
    echo -e "Unrecognised Variable"   
    echo -e "Reloading menu"
    bash build.sh
    fi;   
