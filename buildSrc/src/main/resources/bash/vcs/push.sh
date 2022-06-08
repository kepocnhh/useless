#!/bin/bash

echo "VCS push..."

CODE=0
git push && git push --tag; CODE=$?
if test $CODE -ne 0; then
 echo "Git push failed!"; exit 41
fi

exit 0
