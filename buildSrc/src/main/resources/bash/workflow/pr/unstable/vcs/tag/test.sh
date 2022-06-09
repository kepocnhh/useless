#!/bin/bash

echo "Workflow pull request unstable VCS tag test..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))"

VERSION_NAME="$(jq -Mcer ".version.name|$REQUIRE_FILLED_STRING" assemble/project/common.json)" || exit 1 # todo
TAG="${VERSION_NAME}-UNSTABLE"

CODE=0
/bin/bash $SCRIPTS/vcs/tag/test.sh "$TAG"; CODE=$?
if test $CODE != 0; then
  /bin/bash $SCRIPTS/workflow/pr/unstable/vcs/tag/test/on_failed.sh; exit 11
fi

exit 0
