#!/bin/bash

echo "Workflow pull request unstable VCS release..."

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))"

SCRIPTS=repository/buildSrc/src/main/resources/bash

VERSION_NAME="$(jq -Mcer ".version.name|$REQUIRE_FILLED_STRING" assemble/project/common.json)" || exit 1 # todo
TAG="${VERSION_NAME}-UNSTABLE"

/bin/bash $SCRIPTS/vcs/tag/test.sh "$TAG" || exit 11
/bin/bash $SCRIPTS/vcs/pr/commit.sh || exit 12
/bin/bash $SCRIPTS/workflow/pr/unstable/assemble/project/artifact.sh || exit 13
/bin/bash $SCRIPTS/vcs/push.sh || exit 14
/bin/bash $SCRIPTS/assemble/vcs/commit.sh || exit 15
GIT_COMMIT_SHA="$(jq -Mcer ".sha|$REQUIRE_FILLED_STRING" assemble/vcs/commit.json)" || exit 1 # todo
BODY="$(echo "{}" | jq -Mc ".name=\"$TAG\"")"
BODY="$(echo "$BODY" | jq -Mc ".tag_name=\"$TAG\"")"
BODY="$(echo "$BODY" | jq -Mc ".target_commitish=\"$GIT_COMMIT_SHA\"")"
BODY="$(echo "$BODY" | jq -Mc ".body=\"CI build #$GITHUB_RUN_NUMBER\"")"
BODY="$(echo "$BODY" | jq -Mc ".draft=false")"
BODY="$(echo "$BODY" | jq -Mc ".prerelease=true")"
mkdir -p assemble/github
/bin/bash $SCRIPTS/github/release.sh "$BODY" || exit 16

exit 2 # todo

exit 0
