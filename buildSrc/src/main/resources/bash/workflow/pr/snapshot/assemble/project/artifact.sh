#!/bin/bash

echo "Workflow pull request snapshot assemble project artifact..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

. $SCRIPTS/util/require REPOSITORY_NAME

REPOSITORY=repository
. $SCRIPTS/util/assert -d $REPOSITORY

VERSION_NAME=$($SCRIPTS/util/jqx -sfs assemble/project/common.json .version.name) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
TAG="${VERSION_NAME}-SNAPSHOT"

rm -rf assemble/project/artifact
mkdir -p assemble/project/artifact

ARTIFACT="${REPOSITORY_NAME}-${TAG}.jar"
gradle -p "$REPOSITORY" lib:assembleSnapshotJar \
 || . $SCRIPTS/util/throw 11 "Assemble \"$ARTIFACT\" error $?!"
. $SCRIPTS/util/assert -f $REPOSITORY/lib/build/libs/$ARTIFACT
mv $REPOSITORY/lib/build/libs/$ARTIFACT assemble/project/artifact/$ARTIFACT || exit 1 # todo

ARTIFACT="${REPOSITORY_NAME}-${TAG}-sources.jar"
gradle -p "$REPOSITORY" lib:assembleSnapshotSource \
 || . $SCRIPTS/util/throw 12 "Assemble \"$ARTIFACT\" error $?!"
. $SCRIPTS/util/assert -f $REPOSITORY/lib/build/libs/$ARTIFACT
mv $REPOSITORY/lib/build/libs/$ARTIFACT assemble/project/artifact/$ARTIFACT || exit 1 # todo

ARTIFACT="${REPOSITORY_NAME}-${TAG}.pom"
gradle -p "$REPOSITORY" lib:assembleSnapshotPom \
 || . $SCRIPTS/util/throw 12 "Assemble \"$ARTIFACT\" error $?!"
. $SCRIPTS/util/assert -f $REPOSITORY/lib/build/libs/$ARTIFACT
mv $REPOSITORY/lib/build/libs/$ARTIFACT assemble/project/artifact/$ARTIFACT || exit 1 # todo

exit 0
