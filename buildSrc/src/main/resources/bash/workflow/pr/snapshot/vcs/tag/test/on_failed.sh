#!/bin/bash

echo "Workflow pull request snapshot VCS tag test on failed..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

/bin/bash $SCRIPTS/vcs/pr/close.sh || exit 11 # todo

. $SCRIPTS/util/require REPOSITORY_OWNER REPOSITORY_NAME \
 GITHUB_RUN_NUMBER GITHUB_RUN_ID PR_NUMBER

VERSION_NAME=$($SCRIPTS/util/jqx -sfs assemble/project/common.json .version.name) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
TAG="${VERSION_NAME}-SNAPSHOT"

REPOSITORY_URL=https://github.com/$REPOSITORY_OWNER/$REPOSITORY_NAME

MESSAGE="Closed by CI build [#$GITHUB_RUN_NUMBER]($REPOSITORY_URL/actions/runs/$GITHUB_RUN_ID)
 - tag \`$TAG\` test failed!"

/bin/bash $SCRIPTS/vcs/pr/comment.sh "$MESSAGE" || exit 31 # todo

GIT_COMMIT_SRC=$($SCRIPTS/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json .head.sha) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
AUTHOR_NAME_SRC=$($SCRIPTS/util/jqx -sfs assemble/vcs/commit/author.src.json .name) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
AUTHOR_HTML_URL_SRC=$($SCRIPTS/util/jqx -sfs assemble/vcs/commit/author.src.json .html_url) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
GIT_COMMIT_DST=$($SCRIPTS/util/jqx -sfs assemble/vcs/pr${PR_NUMBER}.json .base.sha) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
AUTHOR_NAME_DST=$($SCRIPTS/util/jqx -sfs assemble/vcs/commit/author.dst.json .name) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
AUTHOR_HTML_URL_DST=$($SCRIPTS/util/jqx -sfs assemble/vcs/commit/author.dst.json .html_url) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
WORKER_NAME=$($SCRIPTS/util/jqx -sfs assemble/vcs/worker.json .name) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
WORKER_HTML_URL=$($SCRIPTS/util/jqx -sfs assemble/vcs/worker.json .html_url) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"

MESSAGE="CI build [#$GITHUB_RUN_NUMBER]($REPOSITORY_URL/actions/runs/$GITHUB_RUN_ID) failed!

[$REPOSITORY_OWNER](https://github.com/$REPOSITORY_OWNER) / [$REPOSITORY_NAME]($REPOSITORY_URL)

The pull request [#$PR_NUMBER]($REPOSITORY_URL/pull/$PR_NUMBER)
 - source [${GIT_COMMIT_SRC::7}]($REPOSITORY_URL/commit/$GIT_COMMIT_SRC) by [$AUTHOR_NAME_SRC]($AUTHOR_HTML_URL_SRC)
 - destination [${GIT_COMMIT_DST::7}]($REPOSITORY_URL/commit/$GIT_COMMIT_DST) by [$AUTHOR_NAME_DST]($AUTHOR_HTML_URL_DST)
 - tag \`$TAG\` test failed!
 - closed by [$WORKER_NAME]($WORKER_HTML_URL)"

/bin/bash $SCRIPTS/notification/telegram/send_message.sh "$MESSAGE" || exit 32

exit 0
