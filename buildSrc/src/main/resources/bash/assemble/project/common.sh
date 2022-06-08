#!/bin/bash

echo "Assemble project common..."

for it in REPOSITORY_OWNER; do
 if test -z "${!it}"; then echo "$it is empty!"; exit 11; fi; done

CODE=0

gradle -p repository saveCommonInfo; CODE=$?
if test $CODE -ne 0; then
 echo "Save common info error $CODE!"
 exit 11
fi

if [ ! -f "repository/build/common.json" ]; then
 echo "File $(pwd)/repository/build/common.json does not exist!"
 exit 21
fi

cp repository/build/common.json assemble/project/common.json

ACTUAL="$(jq -r .repository.owner assemble/project/common.json)"
if test -z "$ACTUAL"; then
 echo "Actual repository owner is empty!"
 exit 41
fi
if test "$REPOSITORY_OWNER" != "$ACTUAL"; then
 echo "Actual repository owner is $ACTUAL, but expected is $REPOSITORY_OWNER!"
 exit 42
fi

exit 0
