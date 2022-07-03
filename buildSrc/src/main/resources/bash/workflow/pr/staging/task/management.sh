#!/bin/bash

echo "Workflow pull request staging task management..."

mkdir -p assemble/github

SCRIPTS=repository/buildSrc/src/main/resources/bash

. $SCRIPTS/util/require REPOSITORY_OWNER REPOSITORY_NAME GITHUB_RUN_NUMBER GITHUB_RUN_ID PR_NUMBER \
 LABEL_ID_SNAPSHOT LABEL_ID_STAGING

GIT_COMMIT_DST=$($SCRIPTS/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json .base.sha) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
GIT_COMMIT_SRC=$($SCRIPTS/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json .head.sha) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"

/bin/bash $SCRIPTS/github/commit/compare.sh "$GIT_COMMIT_DST" "$GIT_COMMIT_SRC" || exit 11 # todo

FILE="assemble/github/commit_compare_${GIT_COMMIT_DST::7}_${GIT_COMMIT_SRC::7}.json"

SIZE=$(jq -e ".commits|length" "$FILE") || exit 1 # todo
REGEX="(^|\s)fix iss/\K[^\W|$]+"
ISSUES=()
for ((i=0; i<SIZE; i++)); do
 it=$($SCRIPTS/util/jqx -sfs "$FILE" ".commits[$i].commit.message") \
  || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
 ISSUES+=($(echo "$it" | grep -Po "$REGEX" | grep -Po "\d+"))
done

VERSION_NAME=$($SCRIPTS/util/jqx -sfs assemble/project/common.json .version.name) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
TAG="${VERSION_NAME}-STAGING"

/bin/bash $SCRIPTS/github/labels.sh || exit 32
SIZE=${#ISSUES[*]}
echo "[]" > assemble/github/fixed.json
ISSUES=($(printf "%s\n" "${ISSUES[@]}" | sort -u))
SIZE=${#ISSUES[*]}
LABEL_ID_TARGET="$LABEL_ID_STAGING"
LABEL_TARGET="$(jq ".[]|select(.id==$LABEL_ID_TARGET)" assemble/github/labels.json)"
LABEL_NAME_TARGET="$(echo "$LABEL_TARGET" | jq -r .name)"
REPOSITORY_URL=https://github.com/$REPOSITORY_OWNER/$REPOSITORY_NAME
TAG_URL="$REPOSITORY_URL/releases/tag/$TAG"
BUILD_URL="$REPOSITORY_URL/actions/runs/$GITHUB_RUN_ID"
MESSAGE="Marked as \`$LABEL_NAME_TARGET\` in [$TAG]($TAG_URL) by CI build [#$GITHUB_RUN_NUMBER]($BUILD_URL)."
for ((i=0; i<SIZE; i++)); do
 ISSUE_NUMBER="${ISSUES[$i]}"
 /bin/bash $SCRIPTS/workflow/pr/staging/task/fix.sh "$ISSUE_NUMBER" "$MESSAGE" || exit 1 # todo
 /bin/bash $SCRIPTS/workflow/pr/task/patch.sh "$ISSUE_NUMBER" "$LABEL_ID_TARGET" || exit 1 # todo
done

/bin/bash $SCRIPTS/workflow/pr/release/note/html.sh "$TAG" || exit 1 # todo
/bin/bash $SCRIPTS/vcs/release/note.sh "$TAG" || exit 1 # todo

exit 0
