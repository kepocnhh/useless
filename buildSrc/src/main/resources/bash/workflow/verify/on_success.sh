#!/bin/bash

echo "Workflow verify on success start..."

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))"

GIT_COMMIT_SHA="$(jq -Mcer ".sha|$REQUIRE_FILLED_STRING" assemble/vcs/commit.json)"
AUTHOR_NAME="$(jq -Mcer ".name|$REQUIRE_FILLED_STRING" assemble/vcs/commit/author.json)"
AUTHOR_URL="$(jq -Mcer ".html_url|$REQUIRE_FILLED_STRING" assemble/vcs/commit/author.json)"

for it in REPOSITORY_OWNER REPOSITORY_NAME \
 GITHUB_RUN_NUMBER GITHUB_RUN_ID \
 GIT_COMMIT_SHA \
 AUTHOR_NAME AUTHOR_URL; do
 if test -z "${!it}"; then echo "$it is empty!"; exit 21; fi; done

REPOSITORY_URL=https://github.com/$REPOSITORY_OWNER/$REPOSITORY_NAME

MESSAGE="CI build [#$GITHUB_RUN_NUMBER]($REPOSITORY_URL/actions/runs/$GITHUB_RUN_ID)

[$REPOSITORY_OWNER](https://github.com/$REPOSITORY_OWNER) / [$REPOSITORY_NAME]($REPOSITORY_URL)

 - source [${GIT_COMMIT_SHA::7}]($REPOSITORY_URL/commit/$GIT_COMMIT_SHA) by [$AUTHOR_NAME]($AUTHOR_URL)

Verified %F0%9F%91%8D"

/bin/bash repository/buildSrc/src/main/resources/bash/notification/telegram/send_message.sh "$MESSAGE" || exit 11

exit 0
