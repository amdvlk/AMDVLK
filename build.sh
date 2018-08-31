#!/bin/bash
cd "$(dirname -- "$(readlink -fn -- "${0}")")"

COMMIT_AMDVLK=de4727d
COMMIT_LLPC=57e0b03
COMMIT_LLVM=32eb74d2
COMMIT_PAL=7ce51b1
COMMIT_XGL=f2c77b7

cd "$HOME"/AMDVLK

if [ ! -f $COMMIT_AMDVLK.zip ]; then wget https://github.com/GPUOpen-Drivers/AMDVLK/archive/$COMMIT_AMDVLK.zip $COMMIT_AMDVLK.zip; fi
if [ ! -f $COMMIT_LLPC.zip   ]; then wget https://github.com/GPUOpen-Drivers/llpc/archive/$COMMIT_LLPC.zip     $COMMIT_LLPC.zip;   fi
if [ ! -f $COMMIT_LLVM.zip   ]; then wget https://github.com/GPUOpen-Drivers/llvm/archive/$COMMIT_LLVM.zip     $COMMIT_LLVM.zip;   fi
if [ ! -f $COMMIT_PAL.zip    ]; then wget https://github.com/GPUOpen-Drivers/pal/archive/$COMMIT_PAL.zip       $COMMIT_PAL.zip;    fi
if [ ! -f $COMMIT_XGL.zip    ]; then wget https://github.com/GPUOpen-Drivers/xgl/archive/$COMMIT_XGL.zip       $COMMIT_XGL.zip;    fi

rm -rf AMDVLK
rm -rf llpc
rm -rf llvm
rm -rf pal
rm -rf xgl

unzip -q $COMMIT_AMDVLK.zip
unzip -q $COMMIT_LLPC.zip
unzip -q $COMMIT_LLVM.zip
unzip -q $COMMIT_PAL.zip
unzip -q $COMMIT_XGL.zip

mv AMDVLK-* AMDVLK
mv llpc-*   llpc
mv llvm-*   llvm
mv pal-*    pal
mv xgl-*    xgl

cp llvm_cmake.patch "$HOME"/AMDVLK
patch -Np1 < llvm_cmake.patch

mkdir -p "$HOME"/AMDVLK/build

cmake -G Ninja -DCMAKE_VERBOSE_MAKEFILE=ON -H"$HOME"/AMDVLK/xgl -B"$HOME"/AMDVLK/build/Release64 -DCMAKE_BUILD_TYPE=Release
cmake -G Ninja -DCMAKE_VERBOSE_MAKEFILE=ON -H"$HOME"/AMDVLK/xgl -B"$HOME"/AMDVLK/build/Debug64   -DCMAKE_BUILD_TYPE=Debug

cd "$HOME"/AMDVLK/build/Release64 && ninja -v | tee "$HOME"/AMDVLK/Release64.log
cd "$HOME"/AMDVLK/build/Debug64   && ninja -v | tee "$HOME"/AMDVLK/Debug64.log
