#!/bin/bash

echo "Assemble VCS commit..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

GIT_COMMIT_SHA="$(git -C repository rev-parse HEAD)" \
 || . $SCRIPTS/util/throw 11 "Get commit SHA error!"

. $SCRIPTS/util/require VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME GIT_COMMIT_SHA

CODE=0
CODE=$(curl -w %{http_code} -o assemble/vcs/commit.json \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/commits/$GIT_COMMIT_SHA")
if test $CODE -ne 200; then
 echo "Get commit $GIT_COMMIT_SHA info error!"
 echo "Request error with response code $CODE!"
 exit 32
fi

COMMIT_HTML_URL=$($SCRIPTS/util/jqx -sfs assemble/vcs/commit.json .html_url) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
AUTHOR_LOGIN=$($SCRIPTS/util/jqx -sfs assemble/vcs/commit.json .author.login) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"

echo "The commit $COMMIT_HTML_URL is ready."

mkdir -p assemble/vcs/commit || exit 1 # todo
CODE=0
CODE=$(curl -w %{http_code} -o assemble/vcs/commit/author.json \
 "$VCS_DOMAIN/users/$AUTHOR_LOGIN")
if test $CODE -ne 200; then
 echo "Get author info error!"
 echo "Request error with response code $CODE!"
 exit 42
fi

AUTHOR_HTML_URL=$($SCRIPTS/util/jqx -sfs assemble/vcs/commit/author.json .html_url) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"

echo "The author $AUTHOR_HTML_URL is ready."

exit 0
