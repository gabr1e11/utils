#!/bin/bash

if [ "$1" == "enable" ]
then
    sudo defaults read com.apple.dt.Xcode IDEIndexDisable 2>/dev/null >/dev/null

    if [ "$?" == "0" ]
    then
        sudo defaults delete com.apple.dt.Xcode IDEIndexDisable
    fi
elif [ "$1" == "disable" ]
then
    sudo defaults write com.apple.dt.XCode IDEIndexDisable 1
else
    echo "Usage: "
    echo "    xcode_indexing.sh [enable | disable]"
    echo ""
fi
