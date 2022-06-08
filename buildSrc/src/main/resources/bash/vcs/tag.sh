#!/bin/bash

echo "VCS tag..."

if test $# -ne 1; then
 echo "Script needs for 1 argument but actual $#"; exit 11
fi

TAG="$1"

CODE=0
git tag "$TAG"; CODE=$?
if test $CODE -ne 0; then
 echo "Git tag failed!"; exit 41
fi

exit 0
