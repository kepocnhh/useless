#!/bin/bash

echo "VCS pull request check state..."

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))"

if test $# -ne 1; then
 echo "Script needs for 1 argument but actual $#"; exit 11
fi

EXPECTED="$1"

for it in VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME PR_NUMBER; do
 if test -z "${!it}"; then echo "$it is empty!"; exit 11; fi; done

CODE=0
CODE=$(curl -w %{http_code} -o assemble/vcs/pr${PR_NUMBER}.json \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/pulls/$PR_NUMBER")
if test $CODE -ne 200; then
 echo "Get pull request #$PR_NUMBER error!"
 echo "Request error with response code $CODE!"
 exit 21
fi

PR_STATE="$(jq -Mcer ".state|$REQUIRE_FILLED_STRING" assemble/vcs/pr${PR_NUMBER}.json)" || exit 1 # todo

if test "$EXPECTED" != "$PR_STATE"; then
 echo "State of pull request #$PR_NUMBER is not \"$EXPECTED\", but it is \"$PR_STATE\"!"; exit 31
fi

exit 0
