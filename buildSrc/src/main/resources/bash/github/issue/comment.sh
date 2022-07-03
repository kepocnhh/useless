#!/bin/bash

echo "GitHub issue comment..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

if test $# -ne 2; then
 echo "Script needs for 2 argument but actual $#"; exit 11
fi

ISSUE_NUMBER="$1"
MESSAGE="$2"

. $SCRIPTS/util/require VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME ISSUE_NUMBER MESSAGE

MESSAGE=${MESSAGE//\"/\\\"}
CODE=$(curl -w %{http_code} -o /tmp/comment.json -X POST \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/issues/$ISSUE_NUMBER/comments" \
 -H "Authorization: token $VCS_PAT" \
 -d "{\"body\":\"$MESSAGE\"}")
if test $CODE -ne 201; then
 echo "GitHub comment issue #$ISSUE_NUMBER error!"
 echo "Request error with response code $CODE!"
 exit 31
fi

COMMENT_HTML_URL=$($SCRIPTS/util/jqx -sfs /tmp/comment.json .html_url) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"

echo "The comment $COMMENT_HTML_URL is ready."

exit 0
