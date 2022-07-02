#!/bin/bash

echo "GitHub release..."

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))" # todo
REQUIRE_INT="select((.!=null)and(type==\"number\"))" # todo

if test $# -ne 1; then
 echo "Script needs for 1 argument but actual $#"; exit 11
fi

BODY="$1"

CODE=0
RELEASE_NAME="$(echo "$BODY" | jq -Mcer ".name|$REQUIRE_FILLED_STRING")"; CODE=$?
if test $CODE -ne 0; then
 echo "Get release name error $CODE!"; exit 12
fi

for it in VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME; do
 if test -z "${!it}"; then echo "$it is empty!"; exit 21; fi; done

CODE=$(curl -w %{http_code} -o assemble/github/release.json -X POST \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/releases" \
 -H "Authorization: token $VCS_PAT" \
 -d "$BODY")
if test $CODE -ne 201; then
 echo "GitHub release $RELEASE_NAME error!"
 echo "Request error with response code $CODE!"
 exit 31
fi

RELEASE_ID="$(jq -Mcer ".id|$REQUIRE_INT" assemble/github/release.json)" || exit 1 # todo
RELEASE_HTML_URL="$(jq -Mcer ".html_url|$REQUIRE_FILLED_STRING" assemble/github/release.json)" || exit 1 # todo

echo "The release $RELEASE_HTML_URL is ready."

exit 0
