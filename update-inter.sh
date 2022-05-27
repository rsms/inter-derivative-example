#!/bin/sh
cd "$(dirname "$0")"

git submodule init
git submodule update
cd inter
git fetch
git merge origin/master
cd ..
bash init.sh
./build/venv/bin/python update-inter.py -pass
