#!/bin/bash

echo "Workflow pull request unstable VCS push..."

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))"

SCRIPTS=repository/buildSrc/src/main/resources/bash

VERSION_NAME="$(jq -Mcer ".version.name|$REQUIRE_FILLED_STRING" assemble/project/common.json)" || exit 1 # todo
TAG="${VERSION_NAME}-UNSTABLE"

/bin/bash $SCRIPTS/vcs/tag/test.sh "$TAG" || exit 11
/bin/bash $SCRIPTS/vcs/pr/commit.sh || exit 12
/bin/bash $SCRIPTS/workflow/pr/unstable/assemble/project/artifact.sh || exit 13
/bin/bash $SCRIPTS/vcs/push.sh || exit 14
/bin/bash $SCRIPTS/assemble/vcs/commit.sh || exit 15

exit 0
