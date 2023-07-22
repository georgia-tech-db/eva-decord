#! /bin/bash

python -m pip install --upgrade pip
pip install twine nose delocate

echo "[install]" > python/setup.cfg
echo "install_lib=" >> python/setup.cfg