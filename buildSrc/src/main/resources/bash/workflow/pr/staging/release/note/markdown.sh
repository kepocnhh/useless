#!/bin/bash

echo "Workflow pull request staging release note markdown..."

if test $# -ne 1; then
 echo "Script needs for 1 argument but actual $#"; exit 11
fi

TAG="$1"

SCRIPTS=repository/buildSrc/src/main/resources/bash

. $SCRIPTS/util/require TAG

RELEASE_NOTE="Release note \`$TAG\`"
SIZE=$(jq -e "length" assemble/github/fixed.json) || exit 1 # todo
if test $SIZE -eq 0; then
 RELEASE_NOTE="$RELEASE_NOTE
 - not a single issue has been resolved"
else
 RELEASE_NOTE="$RELEASE_NOTE
Fixed:"
 FILE="assemble/github/fixed.json"
 for ((i=0; i<SIZE; i++)); do
  ISSUE_NUMBER=$($SCRIPTS/util/jqx -si "$FILE" ".[$i].number") \
   || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
  ISSUE_TITLE=$($SCRIPTS/util/jqx -sfs "$FILE" ".[$i].title") \
   || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
  ISSUE_HTML_URL=$($SCRIPTS/util/jqx -sfs "$FILE" ".[$i].html_url") \
   || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
  RELEASE_NOTE="$RELEASE_NOTE
  - [#$ISSUE_NUMBER]($ISSUE_HTML_URL) $ISSUE_TITLE"
 done
fi

echo "$RELEASE_NOTE" > assemble/github/release_note.md

exit 0
