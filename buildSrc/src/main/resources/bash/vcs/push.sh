#!/bin/bash

echo "VCS push..."

REPOSITORY=repository
[[ -d "$REPOSITORY" ]] || exit 1 # todo

CODE=0
git -C $REPOSITORY push; CODE=$?
if test $CODE -ne 0; then
 echo "Git push failed!"; exit 41
fi

exit 0
