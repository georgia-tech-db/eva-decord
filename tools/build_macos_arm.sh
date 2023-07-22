#!/bin/bash

# this file is actually for building decord for macos >=10.9 on github action

set -e

# pwd
pwd

# build tools
brew install cmake nasm yasm

# cmake > 3.8
cmake --version

# workspace
pushd ~
mkdir ~/ffmpeg_sources

# libx264
cd ~/ffmpeg_sources
git clone --depth 1 https://code.videolan.org/videolan/x264.git
cd x264
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-shared --extra-cflags=-mmacosx-version-min=10.9 --extra-ldflags=-mmacosx-version-min=10.9
make
make install

# libvpx
cd ~/ffmpeg_sources
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
cd libvpx
./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm --enable-shared --extra-cflags=-mmacosx-version-min=10.9 --extra-cxxflags=-mmacosx-version-min=10.9
make
make install

# ffmpeg
cd ~/ffmpeg_sources
curl -O -L https://ffmpeg.org/releases/ffmpeg-5.1.2.tar.bz2
tar xjf ffmpeg-5.1.2.tar.bz2
cd ffmpeg-5.1.2
./configure \
  --prefix="$HOME/ffmpeg_build" \
  --enable-shared \
  --extra-cflags="-mmacosx-version-min=11 -I$HOME/ffmpeg_build/include" \
  --extra-cxxflags="-mmacosx-version-min=11 -I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-mmacosx-version-min=11 -L$HOME/ffmpeg_build/lib" \
  --bindir="$HOME/bin" \
  --enable-gpl \
  --enable-nonfree \
  --enable-libvpx \
  --enable-libx264 \
  --disable-static
mak
make install

# built libs
ls ~/ffmpeg_build/lib

# decord
popd
pwd
mkdir -p build && cd build
cmake .. -DUSE_CUDA=0 -DFFMPEG_DIR="$HOME/ffmpeg_build"
make 
ls -lh
