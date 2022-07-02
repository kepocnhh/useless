#!/bin/bash

echo "Workflow pull request staging task patch..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

if test $# -ne 2; then
 echo "Script needs for 2 argument but actual $#"; exit 11
fi

ISSUE_NUMBER="$1"
LABEL_ID_TARGET="$2"

. $SCRIPTS/util/require ISSUE_NUMBER

LABEL_TARGET="$(jq ".[]|select(.id==$LABEL_ID_TARGET)" assemble/github/labels.json)"
LABEL_NAME_TARGET="$(echo "$LABEL_TARGET" | jq -r .name)"

ISSUE_LABELS="$(jq .labels assemble/github/issue${ISSUE_NUMBER}.json)"
REGEX="^status/\\\\w[\\\\s\\\\w]+$"
QUERY=".[]|select(.name|test(\"$REGEX\")).id"
for it in $(echo "$ISSUE_LABELS" | jq "$QUERY"); do
 ISSUE_LABELS="$(echo "$ISSUE_LABELS" | jq ".|map(select(.id!=$it))")"
done
ISSUE_LABELS="$(echo "$ISSUE_LABELS" | jq ".+[$LABEL_TARGET]")"
ISSUE="$(echo "{}" | jq ".labels=[$ISSUE_LABELS]")"

exit 1 # todo

/bin/bash $SCRIPTS/github/issue/patch.sh "$ISSUE_NUMBER" "$ISSUE" || exit 33
MESSAGE="Test comment $(date +%s) | set label \"$LABEL_NAME_TARGET\""
/bin/bash $SCRIPTS/github/issue/comment.sh "$ISSUE_NUMBER" "$MESSAGE" || exit 34

exit 1 # todo

exit 0
