#!/bin/bash

echo "Workflow pull request snapshot VCS push..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

/bin/bash $SCRIPTS/vcs/pr/commit.sh || exit 11
/bin/bash $SCRIPTS/workflow/pr/snapshot/assemble/project/artifact.sh || exit 21
/bin/bash $SCRIPTS/workflow/pr/snapshot/assemble/project/documentation.sh || exit 22

VERSION_NAME=$($SCRIPTS/util/jqx -sfs assemble/project/common.json .version.name) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
TAG="${VERSION_NAME}-SNAPSHOT"

/bin/bash $SCRIPTS/vcs/documentation/push.sh "$TAG" || exit 31
/bin/bash $SCRIPTS/vcs/push.sh || exit 32
/bin/bash $SCRIPTS/assemble/vcs/commit.sh || exit 41

exit 0
