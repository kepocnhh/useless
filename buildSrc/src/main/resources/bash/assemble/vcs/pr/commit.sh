#!/bin/bash

echo "Assemble VCS pull request commit..."

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))"

for it in VCS_DOMAIN REPOSITORY_OWNER REPOSITORY_NAME PR_NUMBER; do
 if test -z "${!it}"; then echo "$it is empty!"; exit 11; fi; done

GIT_COMMIT_SRC="$(jq -Mcer ".head.sha|$REQUIRE_FILLED_STRING" assemble/vcs/pr${PR_NUMBER}.json)" || exit 1 # todo

CODE=0
CODE=$(curl -w %{http_code} -o assemble/vcs/commit.src.json \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/commits/$GIT_COMMIT_SRC")
if test $CODE -ne 200; then
 echo "Get commit source $GIT_COMMIT_SRC info error!"
 echo "Request error with response code $CODE!"
 exit 21
fi

COMMIT_HTML_URL="$(jq -Mcer ".html_url|$REQUIRE_FILLED_STRING" assemble/vcs/commit.src.json)" || exit 1 # todo
AUTHOR_LOGIN="$(jq -Mcer ".author.login|$REQUIRE_FILLED_STRING" assemble/vcs/commit.src.json)" || exit 1 # todo

echo "The commit source $COMMIT_HTML_URL is ready."

mkdir -p assemble/vcs/commit || exit 1 # todo
CODE=0
CODE=$(curl -w %{http_code} -o assemble/vcs/commit/author.src.json \
 "$VCS_DOMAIN/users/$AUTHOR_LOGIN")
if test $CODE -ne 200; then
 echo "Get author source $AUTHOR_LOGIN info error!"
 echo "Request error with response code $CODE!"
 exit 22
fi

AUTHOR_HTML_URL="$(jq -Mcer ".html_url|$REQUIRE_FILLED_STRING" assemble/vcs/commit/author.src.json)" || exit 1 # todo

echo "The author source $AUTHOR_HTML_URL is ready."

GIT_COMMIT_DST="$(jq -Mcer ".base.sha|$REQUIRE_FILLED_STRING" assemble/vcs/pr${PR_NUMBER}.json)" || exit 1 # todo

CODE=0
CODE=$(curl -w %{http_code} -o assemble/vcs/commit.dst.json \
 "$VCS_DOMAIN/repos/$REPOSITORY_OWNER/$REPOSITORY_NAME/commits/$GIT_COMMIT_DST")
if test $CODE -ne 200; then
 echo "Get commit destination $GIT_COMMIT_DST info error!"
 echo "Request error with response code $CODE!"
 exit 21
fi

COMMIT_HTML_URL="$(jq -Mcer ".html_url|$REQUIRE_FILLED_STRING" assemble/vcs/commit.dst.json)" || exit 1 # todo
AUTHOR_LOGIN="$(jq -Mcer ".author.login|$REQUIRE_FILLED_STRING" assemble/vcs/commit.dst.json)" || exit 1 # todo

echo "The commit destination $COMMIT_HTML_URL is ready."

mkdir -p assemble/vcs/commit || exit 1 # todo
CODE=0
CODE=$(curl -w %{http_code} -o assemble/vcs/commit/author.dst.json \
 "$VCS_DOMAIN/users/$AUTHOR_LOGIN")
if test $CODE -ne 200; then
 echo "Get author destination $AUTHOR_LOGIN info error!"
 echo "Request error with response code $CODE!"
 exit 22
fi

AUTHOR_HTML_URL="$(jq -Mcer ".html_url|$REQUIRE_FILLED_STRING" assemble/vcs/commit/author.dst.json)" || exit 1 # todo

echo "The author destination $AUTHOR_HTML_URL is ready."

exit 0
