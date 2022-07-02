#!/bin/bash

echo "GitHub compare..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

if test $# -ne 2; then
 echo "Script needs for 2 argument but actual $#"; exit 11
fi

GIT_COMMIT_BASE="$1"
GIT_COMMIT_HEAD="$2"

. $SCRIPTS/util/require VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME GIT_COMMIT_BASE GIT_COMMIT_HEAD

FILE="assemble/github/commit_compare_${GIT_COMMIT_BASE::7}_${GIT_COMMIT_HEAD::7}.json"
CODE=$(curl -w %{http_code} -o "$FILE" \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/compare/${GIT_COMMIT_BASE}...${GIT_COMMIT_HEAD}")
if test $CODE -ne 200; then
 echo "GitHub compare ${GIT_COMMIT_BASE}...${GIT_COMMIT_HEAD} error!"
 echo "Request error with response code $CODE!"
 exit 11
fi

COMPARE_HTML_URL=$($SCRIPTS/util/jqx -sfs "$FILE" .html_url) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"

echo "The compare $COMPARE_HTML_URL is ready."

exit 0
