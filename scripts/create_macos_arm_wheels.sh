# Install Pip and Other Dependencies
python -m pip install --upgrade pip
pip install twine nose wheel

# Setup.py Hack
echo "[install]" > python/setup.cfg
echo "install_lib=" >> python/setup.cfg

# Build ffmpeg and decord
chmod +x tools/build_macos_10_9.sh
tools/build_macos_10_9.sh

# Build Wheel
cd python
python setup.py bdist_wheel
find ./dist/ -type f -iname "eva_decord*.whl" -exec sh -c 'mv $0 ${0/\13/11}' {} \;
cd ..

# Fix wheel by delocate
FFMPEG_DIR="$HOME"/ffmpeg_build
python -m pip install delocate
ls -lh ./python/dist/*.whl
find ./python/dist/ -type f -iname "decord*.whl" -exec sh -c "delocate-listdeps '{}'" \;
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
