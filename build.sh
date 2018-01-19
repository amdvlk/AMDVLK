#!/bin/bash
cd "$(dirname -- "$(readlink -fn -- "${0}")")"

COMMIT_AMDVLK=5a93ea2
COMMIT_LLVM=eb5eb1c
COMMIT_PAL=92f481f
COMMIT_XGL=02f11b6

mkdir -p "$HOME"/AMDVLK/build

cp llvm_cmake.patch "$HOME"/AMDVLK
cp xgl_cmake.patch  "$HOME"/AMDVLK

cd "$HOME"/AMDVLK

git clone https://github.com/GPUOpen-Drivers/AMDVLK
git clone https://github.com/GPUOpen-Drivers/llvm
git clone https://github.com/GPUOpen-Drivers/pal
git clone https://github.com/GPUOpen-Drivers/xgl

cd AMDVLK && git reset --hard && git clean -fd && cd ..
cd llvm   && git reset --hard && git clean -fd && cd ..
cd pal    && git reset --hard && git clean -fd && cd ..
cd xgl    && git reset --hard && git clean -fd && cd ..

cd AMDVLK && git checkout -q dev && cd ..
cd llvm   && git checkout -q amd-vulkan-master && cd ..
cd pal    && git checkout -q dev && cd ..
cd xgl    && git checkout -q dev && cd ..

cd AMDVLK && git remote update && cd ..
cd llvm   && git remote update && cd ..
cd pal    && git remote update && cd ..
cd xgl    && git remote update && cd ..

cd AMDVLK && git checkout -q $COMMIT_AMDVLK && cd ..
cd llvm   && git checkout -q $COMMIT_LLVM   && cd ..
cd pal    && git checkout -q $COMMIT_PAL    && cd ..
cd xgl    && git checkout -q $COMMIT_XGL    && cd ..

patch -Np1 < llvm_cmake.patch
patch -Np1 < xgl_cmake.patch

cmake -G Ninja -DCMAKE_VERBOSE_MAKEFILE=ON -H"$HOME"/AMDVLK/xgl -B"$HOME"/AMDVLK/build/Release64 -DCMAKE_BUILD_TYPE=Release -DCMAKE_MODULE_PATH="$HOME"/AMDVLK/pal/cmake/Modules -DXGL_PAL_PATH:PATH="$HOME"/AMDVLK/pal -DCMAKE_C_FLAGS="-DLINUX -D__x86_64__ -D__AMD64__" -DCMAKE_CXX_FLAGS="-DLINUX -D__x86_64__ -D__AMD64__" -DXGL_LLVM_SRC_PATH="$HOME"/AMDVLK/llvm
cmake -G Ninja -DCMAKE_VERBOSE_MAKEFILE=ON -H"$HOME"/AMDVLK/xgl -B"$HOME"/AMDVLK/build/Debug64   -DCMAKE_BUILD_TYPE=Debug   -DCMAKE_MODULE_PATH="$HOME"/AMDVLK/pal/cmake/Modules -DXGL_PAL_PATH:PATH="$HOME"/AMDVLK/pal -DCMAKE_C_FLAGS="-DLINUX -D__x86_64__ -D__AMD64__" -DCMAKE_CXX_FLAGS="-DLINUX -D__x86_64__ -D__AMD64__" -DXGL_LLVM_SRC_PATH="$HOME"/AMDVLK/llvm

cd "$HOME"/AMDVLK/build/Release64 && ninja -v | tee "$HOME"/AMDVLK/Release64.log && cd "$HOME"/AMDVLK/build/Debug64 && ninja -v | tee "$HOME"/AMDVLK/Debug64.log
