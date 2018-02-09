#!/bin/bash
cd "$(dirname -- "$(readlink -fn -- "${0}")")"

COMMIT_AMDVLK=0a6edba
COMMIT_LLVM=a29b390
COMMIT_PAL=5cba4ec
COMMIT_XGL=3340109

mkdir -p "$HOME"/AMDVLK/build

cp llvm_cmake.patch "$HOME"/AMDVLK

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

cmake -G Ninja -DCMAKE_VERBOSE_MAKEFILE=ON -H"$HOME"/AMDVLK/xgl -B"$HOME"/AMDVLK/build/Release64 -DCMAKE_BUILD_TYPE=Release
cmake -G Ninja -DCMAKE_VERBOSE_MAKEFILE=ON -H"$HOME"/AMDVLK/xgl -B"$HOME"/AMDVLK/build/Debug64   -DCMAKE_BUILD_TYPE=Debug

cd "$HOME"/AMDVLK/build/Release64 && ninja -v | tee "$HOME"/AMDVLK/Release64.log && cd "$HOME"/AMDVLK/build/Debug64 && ninja -v | tee "$HOME"/AMDVLK/Debug64.log
