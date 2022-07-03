#!/bin/bash

echo "Workflow pull request snapshot VCS tag test..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

VERSION_NAME=$($SCRIPTS/util/jqx -sfs assemble/project/common.json .version.name) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
TAG="${VERSION_NAME}-SNAPSHOT"

CODE=0
/bin/bash $SCRIPTS/vcs/tag/test.sh "$TAG"; CODE=$?
if test $CODE -ne 0; then
 /bin/bash $SCRIPTS/workflow/pr/snapshot/vcs/tag/test/on_failed.sh; exit 11
fi

exit 0
