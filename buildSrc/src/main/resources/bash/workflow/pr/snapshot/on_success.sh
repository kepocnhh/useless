#!/bin/bash

echo "Workflow pull request snapshot on success start..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

. $SCRIPTS/util/require REPOSITORY_OWNER REPOSITORY_NAME GITHUB_RUN_NUMBER GITHUB_RUN_ID PR_NUMBER MAVEN_GROUP_ID MAVEN_ARTIFACT_ID

GIT_COMMIT_SHA=$($SCRIPTS/util/jqx -sfs assemble/vcs/commit.json .sha) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
AUTHOR_NAME=$($SCRIPTS/util/jqx -sfs assemble/vcs/commit/author.json .name) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
AUTHOR_HTML_URL=$($SCRIPTS/util/jqx -sfs assemble/vcs/commit/author.json .html_url) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
WORKER_NAME=$($SCRIPTS/util/jqx -sfs assemble/vcs/worker.json .name) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
WORKER_HTML_URL=$($SCRIPTS/util/jqx -sfs assemble/vcs/worker.json .html_url) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"

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

VERSION_NAME=$($SCRIPTS/util/jqx -sfs assemble/project/common.json .version.name) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
TAG="${VERSION_NAME}-SNAPSHOT"

REPOSITORY_URL=https://github.com/$REPOSITORY_OWNER/$REPOSITORY_NAME
PAGES_URL="https://${REPOSITORY_OWNER}.github.io/$REPOSITORY_NAME"
RELEASE_NOTE_URL="$PAGES_URL/build/$GITHUB_RUN_NUMBER/$GITHUB_RUN_ID/release/note/index.html"
DOCUMENTATION_URL="$PAGES_URL/build/$GITHUB_RUN_NUMBER/$GITHUB_RUN_ID/documentation/$TAG/index.html"
TAG_URL="$REPOSITORY_URL/releases/tag/$TAG"
MAVEN_URL="https://s01.oss.sonatype.org/content/repositories/snapshots"

REPORT=" - tag [$TAG]($TAG_URL)
 - maven [snapshot](${MAVEN_URL}/${MAVEN_GROUP_ID//.//}/${MAVEN_ARTIFACT_ID}/${TAG})
 - documentation [here]($DOCUMENTATION_URL)
 - release [note]($RELEASE_NOTE_URL)"

MESSAGE="Merged by CI build [#$GITHUB_RUN_NUMBER]($REPOSITORY_URL/actions/runs/$GITHUB_RUN_ID)
$REPORT"

/bin/bash $SCRIPTS/vcs/pr/comment.sh "$MESSAGE" || exit 31 # todo

MESSAGE="CI build [#$GITHUB_RUN_NUMBER]($REPOSITORY_URL/actions/runs/$GITHUB_RUN_ID)

[$REPOSITORY_OWNER](https://github.com/$REPOSITORY_OWNER) / [$REPOSITORY_NAME]($REPOSITORY_URL)

\`*\` [${GIT_COMMIT_SHA::7}]($REPOSITORY_URL/commit/$GIT_COMMIT_SHA) by [$AUTHOR_NAME]($AUTHOR_HTML_URL)
\`|\\\`
\`| *\` [${GIT_COMMIT_SRC::7}]($REPOSITORY_URL/commit/$GIT_COMMIT_SRC) by [$AUTHOR_NAME_SRC]($AUTHOR_HTML_URL_SRC)
\`*\` [${GIT_COMMIT_DST::7}]($REPOSITORY_URL/commit/$GIT_COMMIT_DST) by [$AUTHOR_NAME_DST]($AUTHOR_HTML_URL_DST)

The pull request [#$PR_NUMBER]($REPOSITORY_URL/pull/$PR_NUMBER) merged by [$WORKER_NAME]($WORKER_HTML_URL)
$REPORT"

/bin/bash $SCRIPTS/notification/telegram/send_message.sh "$MESSAGE" || exit 32

exit 0
