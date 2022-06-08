#!/bin/bash

echo "Workflow verify on failed start..."

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))"

GIT_COMMIT_SHA="$(jq -cerM ".sha|$REQUIRE_FILLED_STRING" assemble/vcs/commit.json)"
AUTHOR_NAME="$(jq -cerM ".name|$REQUIRE_FILLED_STRING" assemble/vcs/commit/author.json)"
AUTHOR_URL="$(jq -cerM ".html_url|$REQUIRE_FILLED_STRING" assemble/vcs/commit/author.json)"

for it in REPOSITORY_OWNER REPOSITORY_NAME \
 GITHUB_RUN_NUMBER GITHUB_RUN_ID \
 GIT_COMMIT_SHA \
 AUTHOR_NAME AUTHOR_URL; do
 if test -z "${!it}"; then echo "$it is empty!"; exit 21; fi; done

VERIFY_RESULT=" - see the report:"
ENVIRONMENT=diagnostics/summary.json
TYPES=($(jq -Mcer "keys|.[]" $ENVIRONMENT))
SIZE=${#TYPES[*]}
if test $SIZE == 0; then
 echo "Diagnostics should have determined the cause of the failure!"; exit 1
fi
PAGES_URL="https://${REPOSITORY_OWNER}.github.io/$REPOSITORY_NAME"
REPORT_PATH=$GITHUB_RUN_NUMBER/$GITHUB_RUN_ID/diagnostics/report
for ((i=0; i<SIZE; i++)); do
 TYPE="${TYPES[i]}"
 RELATIVE="$(jq -Mcer ".${TYPE}.path|$REQUIRE_FILLED_STRING" $ENVIRONMENT)" || exit 1 # todo
 TITLE="$(jq -Mcer ".${TYPE}.title|$REQUIRE_FILLED_STRING" $ENVIRONMENT)" || exit 1 # todo
 VERIFY_RESULT="${VERIFY_RESULT}
    $((i+1))) [$TITLE](${PAGES_URL}/build/$REPORT_PATH/$RELATIVE/index.html)"
done

REPOSITORY_URL=https://github.com/$REPOSITORY_OWNER/$REPOSITORY_NAME

MESSAGE="CI build [#$GITHUB_RUN_NUMBER]($REPOSITORY_URL/actions/runs/$GITHUB_RUN_ID) failed!

[$REPOSITORY_OWNER](https://github.com/$REPOSITORY_OWNER) / [$REPOSITORY_NAME]($REPOSITORY_URL)

 - source [${GIT_COMMIT_SHA::7}]($REPOSITORY_URL/commit/$GIT_COMMIT_SHA) by [$AUTHOR_NAME]($AUTHOR_URL)
$VERIFY_RESULT"

/bin/bash repository/buildSrc/src/main/resources/bash/notification/telegram/send_message.sh "$MESSAGE" || exit 31

exit 0
