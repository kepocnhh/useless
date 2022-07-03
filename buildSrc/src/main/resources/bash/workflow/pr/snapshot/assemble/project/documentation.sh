#!/bin/bash

echo "Workflow pull request snapshot assemble project documentation..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

REPOSITORY=repository
. $SCRIPTS/util/assert -d $REPOSITORY

gradle -p "$REPOSITORY" lib:assembleSnapshotDocumentation \
 || . $SCRIPTS/util/throw 11 "Assemble documentation error $?!"

DOCUMENTATION_PATH=$REPOSITORY/lib/build/documentation/snapshot
. $SCRIPTS/util/assert -d $DOCUMENTATION_PATH

rm -rf assemble/project/documentation
mkdir -p assemble/project/documentation
cp -r $DOCUMENTATION_PATH/* assemble/project/documentation || exit 1 # todo

exit 0
