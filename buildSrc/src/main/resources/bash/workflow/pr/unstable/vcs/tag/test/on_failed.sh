#!/bin/bash

echo "Workflow pull request unstable VCS tag test on failed..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

/bin/bash $SCRIPTS/vcs/pr/close.sh || exit 11 # todo

for it in REPOSITORY_OWNER REPOSITORY_NAME \
 GITHUB_RUN_NUMBER GITHUB_RUN_ID PR_NUMBER; do
 if test -z "${!it}"; then echo "$it is empty!"; exit 21; fi; done

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))"

VERSION_NAME="$(jq -Mcer ".version.name|$REQUIRE_FILLED_STRING" assemble/project/common.json)" || exit 1 # todo
TAG="${VERSION_NAME}-UNSTABLE"

REPOSITORY_URL=https://github.com/$REPOSITORY_OWNER/$REPOSITORY_NAME

MESSAGE="Closed by CI build [#$GITHUB_RUN_NUMBER]($REPOSITORY_URL/actions/runs/$GITHUB_RUN_ID)
 - tag \"$TAG\" test  failed!"

/bin/bash $SCRIPTS/vcs/pr/comment.sh "$MESSAGE" || exit 31 # todo

# todo message telegram

exit 3 # todo

exit 0
