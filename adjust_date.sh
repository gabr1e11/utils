#!/bin/bash
export PATH="$PWD:$PATH"

git pull

git filter-branch -f --env-filter '
if [ "$GIT_COMMIT" != "1123dc9362b4512437dce0d7864df6b697b15527" ]; then
    GIT_AUTHOR_DATE=`adjust_date.py --date $GIT_AUTHOR_DATE`
	GIT_AUTHOR_NAME="Roberto Cano"
	GIT_COMMITTER_NAME="Roberto Cano"
	GIT_AUTHOR_EMAIL="gabr1e11@hotmail.com"
	GIT_COMMITTER_EMAIL="gabr1e11@hotmai.com"
fi
'

git push -f origin
git push -f downstream
