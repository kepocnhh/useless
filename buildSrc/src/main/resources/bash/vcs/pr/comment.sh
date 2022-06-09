#!/bin/bash

echo "VCS pull request comment..."

if test $# -ne 1; then
 echo "Script needs for 1 argument but actual $#"; exit 11
fi

COMMENT="$1"

for it in VCS_DOMAIN VCS_PAT REPOSITORY_OWNER REPOSITORY_NAME PR_NUMBER; do
 if test -z "${!it}"; then echo "$it is empty!"; exit 21; fi; done

BODY="$(echo "{}" | jq -Mc ".body=\"$COMMENT\"")"

CODE=0
CODE=$(curl -w %{http_code} -o assemble/github/release.json -X POST \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/issues/$PR_NUMBER/comments" \
 -H "Authorization: token $VCS_PAT" \
 -d "$BODY")
if test $CODE -ne 201; then
 echo "Post comment to pull request #$PR_NUMBER error!"
 echo "Request error with response code $CODE!"
 exit 31
fi

exit 0
