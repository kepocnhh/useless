#!/bin/bash

echo "Workflow pull request staging VCS push..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

/bin/bash $SCRIPTS/vcs/pr/commit.sh || exit 12

VERSION_NAME=$($SCRIPTS/util/jqx -sfs assemble/project/common.json .version.name) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
TAG="${VERSION_NAME}-STAGING"

/bin/bash $SCRIPTS/vcs/tag.sh "$TAG" || exit 13
/bin/bash $SCRIPTS/vcs/push.sh || exit 14
/bin/bash $SCRIPTS/vcs/tag/push.sh || exit 15
/bin/bash $SCRIPTS/assemble/vcs/commit.sh || exit 21

exit 0
