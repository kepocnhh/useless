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
 WORKER_NAME WORKER_EMAIL; do
 if test -z "${!it}"; then echo "$it is empty!"; exit 21; fi; done

exit 1 # todo

exit 0
