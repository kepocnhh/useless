#!/bin/bash

echo "GitHub issue..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

if test $# -ne 1; then
 echo "Script needs for 1 argument but actual $#"; exit 11
fi

ISSUE_NUMBER="$1"

. $SCRIPTS/util/require VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME ISSUE_NUMBER

CODE=$(curl -w %{http_code} -o assemble/github/issue${ISSUE_NUMBER}.json \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/issues/$ISSUE_NUMBER")
if test $CODE -ne 200; then
 echo "GitHub issue #$ISSUE_NUMBER error!"
 echo "Request error with response code $CODE!"
 exit 11
fi

ISSUE_HTML_URL=$($SCRIPTS/util/jqx -sfs assemble/github/issue${ISSUE_NUMBER}.json .html_url) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"

echo "The issue $ISSUE_HTML_URL is ready."

exit 0
