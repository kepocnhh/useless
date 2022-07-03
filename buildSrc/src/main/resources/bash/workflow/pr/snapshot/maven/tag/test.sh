#!/bin/bash

echo "Workflow pull request snapshot maven tag test..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

. $SCRIPTS/util/require MAVEN_GROUP_ID MAVEN_ARTIFACT_ID

BASE_URL="https://s01.oss.sonatype.org/content/repositories/snapshots/${MAVEN_GROUP_ID//.//}"

VERSION_NAME=$($SCRIPTS/util/jqx -sfs assemble/project/common.json .version.name) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
TAG="${VERSION_NAME}-SNAPSHOT"

CODE=0
CODE=$(curl -w %{http_code} -o /dev/null \
 "${BASE_URL}/${MAVEN_ARTIFACT_ID}/${TAG}/")
if test $CODE -ne 404; then
 /bin/bash $SCRIPTS/workflow/pr/snapshot/maven/tag/test/on_failed.sh; exit 11
fi

exit 0
