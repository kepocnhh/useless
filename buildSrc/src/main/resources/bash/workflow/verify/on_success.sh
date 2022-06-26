#!/bin/bash

echo "Workflow verify on success start..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

. $SCRIPTS/util/require REPOSITORY_OWNER REPOSITORY_NAME GITHUB_RUN_NUMBER GITHUB_RUN_ID

GIT_COMMIT_SHA=$($SCRIPTS/util/jqx -sfs assemble/vcs/commit.json .sha) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
AUTHOR_NAME=$($SCRIPTS/util/jqx -sfs assemble/vcs/commit/author.json .name) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
AUTHOR_HTML_URL=$($SCRIPTS/util/jqx -sfs assemble/vcs/commit/author.json .html_url) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"

REPOSITORY_URL=https://github.com/$REPOSITORY_OWNER/$REPOSITORY_NAME

MESSAGE="CI build [#$GITHUB_RUN_NUMBER]($REPOSITORY_URL/actions/runs/$GITHUB_RUN_ID)

[$REPOSITORY_OWNER](https://github.com/$REPOSITORY_OWNER) / [$REPOSITORY_NAME]($REPOSITORY_URL)

The commit [${GIT_COMMIT_SHA::7}]($REPOSITORY_URL/commit/$GIT_COMMIT_SHA) by [$AUTHOR_NAME]($AUTHOR_HTML_URL) is verified %F0%9F%91%8D"

/bin/bash repository/buildSrc/src/main/resources/bash/notification/telegram/send_message.sh "$MESSAGE" || exit 11

exit 0
