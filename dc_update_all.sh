#!/bin/zsh
git pull
git submodule update
./tools/generate_ios.sh
