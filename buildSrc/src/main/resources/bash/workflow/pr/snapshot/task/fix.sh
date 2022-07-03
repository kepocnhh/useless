#!/bin/bash

echo "Workflow pull request snapshot task fix..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

if test $# -ne 2; then
 echo "Script needs for 2 argument but actual $#"; exit 11
fi

ISSUE_NUMBER="$1"
MESSAGE="$2"

. $SCRIPTS/util/require ISSUE_NUMBER MESSAGE

for ((i=0; i<SIZE; i++)); do
 ISSUE_NUMBER="${ISSUES[$i]}"
 /bin/bash $SCRIPTS/github/issue.sh "$ISSUE_NUMBER" || exit 1 # todo
 IS_TESTED="$(jq ".labels|any(.id==$LABEL_ID_TARGET)" assemble/github/issue${ISSUE_NUMBER}.json)"
 IS_READY_FOR_TEST="$(jq ".labels|any(.id==$LABEL_ID_STAGING)" assemble/github/issue${ISSUE_NUMBER}.json)"
 if test "$IS_TESTED" == "true"; then
  echo echo "The issue #$ISSUE_NUMBER is already marked as \`$LABEL_NAME_TARGET\`."
 elif test "$IS_TESTED" == "false"; then
  if test "$IS_READY_FOR_TEST" == "true"; then
   /bin/bash $SCRIPTS/github/issue/comment.sh "$ISSUE_NUMBER" "$MESSAGE" || exit 1 # todo
   echo "$(jq ".+[$(cat assemble/github/issue${ISSUE_NUMBER}.json)]" assemble/github/fixed.json)" \
    > assemble/github/fixed.json || exit 1
  elif test "$IS_READY_FOR_TEST" == "false"; then
   echo "The issue #$ISSUE_NUMBER is not ready for test."
  else
   echo "The issue #$ISSUE_NUMBER label \"$LABEL_ID_STAGING\" error!"; exit 1 # todo
  fi
 else
  echo "The issue #$ISSUE_NUMBER label \"$LABEL_ID_TARGET\" error!"; exit 1 # todo
 fi
 /bin/bash $SCRIPTS/workflow/pr/task/patch.sh "$ISSUE_NUMBER" "$LABEL_ID_TARGET" || exit 1 # todo util
done

/bin/bash $SCRIPTS/github/issue.sh "$ISSUE_NUMBER" || exit 1 # todo

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

LABEL_ID=$LABEL_ID_STAGING
IS_READY_FOR_TEST="$(jq ".labels|any(.id==$LABEL_ID)" assemble/github/issue${ISSUE_NUMBER}.json)"
LABEL_NAME="$(echo "$(jq ".[]|select(.id==$LABEL_ID)" assemble/github/labels.json)" | jq -r .name)"
if test "$IS_READY_FOR_TEST" == "false"; then
 echo "The issue #$ISSUE_NUMBER is already marked as \"$LABEL_NAME\"."
 exit 0
elif test "$IS_READY_FOR_TEST" != "true"; then
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
