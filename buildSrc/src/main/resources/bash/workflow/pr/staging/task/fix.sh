#!/bin/bash

echo "Workflow pull request staging task fix..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

if test $# -ne 2; then
 echo "Script needs for 2 argument but actual $#"; exit 11
fi

ISSUE_NUMBER="$1"
MESSAGE="$2"

. $SCRIPTS/util/require ISSUE_NUMBER MESSAGE

LABEL_TARGET="$(jq ".[]|select(.id==$LABEL_ID_STAGING)" assemble/github/labels.json)"
LABEL_NAME_TARGET="$(echo "$LABEL_TARGET" | jq -r .name)"

/bin/bash $SCRIPTS/github/issue.sh "$ISSUE_NUMBER" || exit 1 # todo

LABEL_ID=$LABEL_ID_STAGING
IS_READY_FOR_TEST="$(jq ".labels|any(.id==$LABEL_ID)" assemble/github/issue${ISSUE_NUMBER}.json)"
LABEL_NAME="$(echo "$(jq ".[]|select(.id==$LABEL_ID)" assemble/github/labels.json)" | jq -r .name)"
if test "$IS_READY_FOR_TEST" == "true"; then
 echo "The issue #$ISSUE_NUMBER is already marked as \"$LABEL_NAME\"."
 exit 0
fi
if test "$IS_READY_FOR_TEST" != "false"; then
 echo "The issue #$ISSUE_NUMBER label \"$LABEL_NAME\" error!"
 exit 2
fi

LABEL_ID=$LABEL_ID_SNAPSHOT
IS_TESTED="$(jq ".labels|any(.id==$LABEL_ID)" assemble/github/issue${ISSUE_NUMBER}.json)"
LABEL_NAME="$(echo "$(jq ".[]|select(.id==$LABEL_ID)" assemble/github/labels.json)" | jq -r .name)"
if test "$IS_TESTED" == "true"; then
 echo "The issue #$ISSUE_NUMBER is already marked as \"$LABEL_NAME\"."
 exit 0
fi
if test "$IS_TESTED" != "false"; then
 echo "The issue #$ISSUE_NUMBER label \"$LABEL_NAME\" error!"
 exit 2
fi

ISSUE_STATE=$($SCRIPTS/util/jqx -sfs assemble/github/issue${ISSUE_NUMBER}.json .state) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
if test "$ISSUE_STATE" == "closed"; then
 echo "The issue #$ISSUE_NUMBER is closed."
 exit 0
fi
if test "$IS_TESTED" != "open"; then
 echo "The issue #$ISSUE_NUMBER state error!"
 exit 2
fi

/bin/bash $SCRIPTS/github/issue/comment.sh "$ISSUE_NUMBER" "$MESSAGE" || exit 1 # todo
echo "$(jq ".+[$(cat assemble/github/issue${ISSUE_NUMBER}.json)]" assemble/github/fixed.json)" \
 > assemble/github/fixed.json || exit 1 # todo

exit 0
