#!/bin/bash

function die()
{
    if [ "$?" != "0" ]; then
    	echo "ERROR: $1"
	exit $?
    fi
}

CONTINUE=

echo "This will erase all previous commits and leave only the last one in the remote repository!!"
echo -ne "Are you sure? [y/N] "

read CONTINUE

if [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ]; then
    echo "Exiting..."
    exit 1
fi

echo "Removing all commits except last..."

GIT_URL=`git remote get-url origin`
GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`

rm -rf .git 2> /dev/null

git init
die "Re-initializing git repository"

git add .
die "Re-adding current sources to repository"

git commit -m "Initial commit"
die "Creating initial commit"

git remote add origin $GIT_URL
die "Setting remote URL to $GIT_URL"

git push -u --force origin $GIT_BRANCH
die "Force-pushing repository to branch $GIT_BRANCH"

echo ""
echo "Done!"
echo ""
