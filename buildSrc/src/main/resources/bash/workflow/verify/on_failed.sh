#!/bin/bash

echo "Workflow verify on failed start..."

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))"

WORKER_NAME="$(jq -cerM ".name|$REQUIRE_FILLED_STRING" assemble/vcs/worker.json)"
WORKER_VCS_EMAIL="$(jq -cerM ".vcs_email|$REQUIRE_FILLED_STRING" assemble/vcs/worker.json)"
GIT_COMMIT_SHA="$(jq -cerM ".sha|$REQUIRE_FILLED_STRING" assemble/vcs/commit.json)"
AUTHOR_NAME="$(jq -cerM ".name|$REQUIRE_FILLED_STRING" assemble/vcs/commit/author.json)"
AUTHOR_URL="$(jq -cerM ".html_url|$REQUIRE_FILLED_STRING" assemble/vcs/commit/author.json)"

for it in REPOSITORY_OWNER REPOSITORY_NAME \
 GITHUB_RUN_NUMBER GITHUB_RUN_ID \
 GIT_COMMIT_SHA \
 AUTHOR_NAME AUTHOR_URL \
 WORKER_NAME WORKER_VCS_EMAIL; do
 if test -z "${!it}"; then echo "$it is empty!"; exit 21; fi; done

VERIFY_RESULT=" - see the report:"
ENVIRONMENT=diagnostics/summary.json
TYPES="$(jq -Mcer "keys|.[]" $ENVIRONMENT)" || exit 1 # todo
SIZE=${#TYPES[*]}
if test $SIZE == 0; then
 echo "Diagnostics should have determined the cause of the failure!"; exit 1
fi
PAGES_URL="https://${REPOSITORY_OWNER}.github.io/$REPOSITORY_NAME"
REPORT_PATH=$GITHUB_RUN_NUMBER/$GITHUB_RUN_ID/diagnostics/report
for ((i=0; i<SIZE; i++)); do
 TYPE="${TYPES[i]}"
 RELATIVE="$(jq -Mcer ".${TYPE}.path|$REQUIRE_FILLED_STRING" $ENVIRONMENT)" || exit 1 # todo
 VERIFY_RESULT="${VERIFY_RESULT}
    $((i+1))) [$TYPE](${PAGES_URL}/build/$REPORT_PATH/$RELATIVE/index.html)"
done

echo "VERIFY_RESULT:
$VERIFY_RESULT" # todo
exit 1 # todo

exit 0
