#!/bin/bash

echo "GitHub issue patch..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

if test $# -ne 2; then
 echo "Script needs for 2 argument but actual $#"; exit 11
fi

ISSUE_NUMBER="$1"
BODY="$2"

. $SCRIPTS/util/require VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME ISSUE_NUMBER BODY

CODE=$(curl -w %{http_code} -o assemble/github/issue${ISSUE_NUMBER}.json -X PATCH \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/issues/$ISSUE_NUMBER" \
 -H "Authorization: token $VCS_PAT" \
 -d "$BODY")
if test $CODE -ne 200; then
 echo "GitHub patch issue #$ISSUE_NUMBER error!"
 echo "Request error with response code $CODE!"
 exit 31
fi

ISSUE_HTML_URL=$($SCRIPTS/util/jqx -sfs assemble/github/issue${ISSUE_NUMBER}.json .html_url) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"

echo "The issue $ISSUE_HTML_URL is patched."

exit 0
