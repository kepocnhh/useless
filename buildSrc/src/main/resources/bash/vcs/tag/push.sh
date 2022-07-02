#!/bin/bash

echo "VCS tag push..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

REPOSITORY=repository
. $SCRIPTS/util/assert -d $REPOSITORY

git -C $REPOSITORY push --tag \
 || . $SCRIPTS/util/throw 41 "Git tag push error!"

exit 0
