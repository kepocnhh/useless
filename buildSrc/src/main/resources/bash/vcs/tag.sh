#!/bin/bash

echo "VCS tag..."

if test $# -ne 1; then
 echo "Script needs for 1 argument but actual $#"; exit 11
fi

TAG="$1"

SCRIPTS=repository/buildSrc/src/main/resources/bash

REPOSITORY=repository
. $SCRIPTS/util/assert -d $REPOSITORY

git -C $REPOSITORY tag "$TAG" \
 || . $SCRIPTS/util/throw 41 "Git tag error!"

exit 0
