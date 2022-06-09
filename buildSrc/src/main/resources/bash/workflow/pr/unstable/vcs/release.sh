#!/bin/bash

echo "Workflow pull request unstable VCS release..."

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))"

SCRIPTS=repository/buildSrc/src/main/resources/bash

VERSION_NAME="$(jq -Mcer ".version.name|$REQUIRE_FILLED_STRING" assemble/project/common.json)" || exit 1 # todo
TAG="${VERSION_NAME}-UNSTABLE"

GIT_COMMIT_SHA="$(jq -Mcer ".sha|$REQUIRE_FILLED_STRING" assemble/vcs/commit.json)" || exit 1 # todo
BODY="$(echo "{}" | jq -Mc ".name=\"$TAG\"")"
BODY="$(echo "$BODY" | jq -Mc ".tag_name=\"$TAG\"")"
BODY="$(echo "$BODY" | jq -Mc ".target_commitish=\"$GIT_COMMIT_SHA\"")"
BODY="$(echo "$BODY" | jq -Mc ".body=\"CI build #$GITHUB_RUN_NUMBER\"")"
BODY="$(echo "$BODY" | jq -Mc ".draft=false")"
BODY="$(echo "$BODY" | jq -Mc ".prerelease=true")"
mkdir -p assemble/github
/bin/bash $SCRIPTS/github/release.sh "$BODY" || exit 16

ARTIFACT_NAME="${REPOSITORY_NAME}-${TAG}.jar"
ARTIFACT="$(echo "{}" | jq -Mc ".name=\"$ARTIFACT_NAME\"")"
ARTIFACT="$(echo "$ARTIFACT" | jq -Mc ".label=\"$ARTIFACT_NAME\"")"
ARTIFACT="$(echo "$ARTIFACT" | jq -Mc ".path=\"assemble/project/artifact/$ARTIFACT_NAME\"")"
ARTIFACTS="$(echo "[]" | jq -Mc ".+=[$ARTIFACT]")"
/bin/bash $SCRIPTS/github/release/upload/artifact.sh "$ARTIFACTS" || exit 17

exit 0
