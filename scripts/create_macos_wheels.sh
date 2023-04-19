#!/bin/bash

# Set default values for options
arch="intel"
target_version="10_9"
build_ffmpeg=false

# Parse command-line options
while getopts ":a:f" opt; do
    case ${opt} in
    a) # Specify architecture
        arch=$OPTARG
        ;;
    f) # Build ffmpeg
        build_ffmpeg=true
        ;;
    \?) # Invalid option
        echo "Usage: $0 [-a arm|intel] [-f]" 1>&2
        exit 1
        ;;
    esac
done
shift $((OPTIND - 1))

# run the build script only if the build_ffmpeg flag is set
if [ "$build_ffmpeg" = true ]; then
    if [ "$arch" == "arm" ]; then
        target_version="11_0"
        chmod +x tools/build_macos_arm.sh
        tools/build_macos_arm.sh
    elif [ "$arch" == "intel" ]; then
        chmod +x tools/build_macos_intel.sh
        tools/build_macos_intel.sh
    else
        echo "Invalid architecture: $arch"
        exit 1
    fi
fi

# Install Pip and Other Dependencies
python -m pip install --upgrade pip
pip install twine nose wheel delocate
source source ~/.bashrc

# Setup.py Hack
echo "[install]" >python/setup.cfg
echo "install_lib=" >>python/setup.cfg

# Build Wheel
cd python
python setup.py bdist_wheel
find ./dist/ -type f -iname "eva_decord*.whl" -exec sh -c 'new_filename=$(echo "$0" | sed -E "s/_[0-9]*_[0-9]*/'"_${target_version}"'/"); mv "$0" "$new_filename"' {} \;
cd ..

# Fix wheel by delocate
FFMPEG_DIR="$HOME"/ffmpeg_build
ls -lh ./python/dist/*.whl
find ./python/dist/ -type f -iname "eva_decord*.whl" -exec sh -c "delocate-listdeps '{}'" \;
mkdir -p ./python/dist/fixed_wheel
cd ./python/dist/
cp "$FFMPEG_DIR"/lib/libvpx*.dylib .
find . -type f -iname "eva_decord*.whl" -exec sh -c "delocate-wheel -w fixed_wheel -v '{}'" \;
ls -lh ./fixed_wheel
cd ../../

# Sanity Test
ls ./python/dist/fixed_wheel
find ./python/dist/fixed_wheel -type f -iname "eva_decord*.whl" -exec sh -c "python -m pip install '{}'" \;
# python -m nose -v ./tests/python/unittests/test_video_reader.py
