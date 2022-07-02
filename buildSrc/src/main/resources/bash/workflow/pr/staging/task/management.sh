#!/bin/bash

echo "Workflow pull request staging task management..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

. $SCRIPTS/util/require PR_NUMBER

GIT_COMMIT_DST=$($SCRIPTS/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json .base.sha) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
GIT_COMMIT_SRC=$($SCRIPTS/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json .head.sha) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"

/bin/bash $SCRIPTS/github/commit/compare.sh "$GIT_COMMIT_DST" "$GIT_COMMIT_SRC" || exit 11 # todo

FILE="assemble/github/commit/compare_${GIT_COMMIT_DST::7}_${GIT_COMMIT_SRC::7}.json"

SIZE=$(jq -e ".commits|length" "$FILE") || exit 1 # todo
REGEX="(^|\s)fix iss/\K[^\W|$]+"
ISSUES=()
for ((i=0; i<SIZE; i++)); do
 it=$($SCRIPTS/util/jqx -sfs "$FILE" ".commits[$i].commit.message") \
  || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
 ISSUES+=($(echo "$it" | grep -Po "$REGEX" | grep -Po "\d+"))
done

mkdir -p assemble/github

SIZE=${#ISSUES[*]}
echo "[]" > assemble/github/fixed.json
ISSUES=($(printf "%s\n" "${ISSUES[@]}" | sort -u))
SIZE=${#ISSUES[*]}
for ((i=0; i<SIZE; i++)); do
 ISSUE_NUMBER="${ISSUES[$i]}"
 /bin/bash $SCRIPTS/github/issue.sh "$ISSUE_NUMBER" || exit 1 # todo
 echo "$(jq ".+[$(cat assemble/github/issue${ISSUE_NUMBER}.json)]" assemble/github/fixed.json)" \
  > assemble/github/fixed.json || exit 1 # todo
done

VERSION_NAME=$($SCRIPTS/util/jqx -sfs assemble/project/common.json .version.name) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
TAG="${VERSION_NAME}-STAGING"
/bin/bash $SCRIPTS/workflow/pr/staging/release/note/markdown.sh "$TAG" || exit 1 # todo
/bin/bash $SCRIPTS/workflow/pr/staging/release/note/html.sh "$TAG" || exit 1 # todo

cat assemble/github/release_note.md
cat assemble/github/release_note.html

exit 1 # todo

exit 0
