#!/bin/bash

echo "VCS diagnostics report..."

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))"

WORKER_NAME="$(jq -cerM ".name|$REQUIRE_FILLED_STRING" assemble/vcs/worker.json)"
WORKER_VCS_EMAIL="$(jq -cerM ".vcs_email|$REQUIRE_FILLED_STRING" assemble/vcs/worker.json)"

for it in VCS_PAT REPOSITORY_OWNER REPOSITORY_NAME \
 GITHUB_RUN_NUMBER GITHUB_RUN_ID \
 WORKER_NAME WORKER_VCS_EMAIL; do
 if test -z "${!it}"; then echo "$it is empty!"; exit 21; fi; done

REPOSITORY=pages/diagnostics/report
mkdir -p $REPOSITORY || exit 1 # todo

git -C $REPOSITORY init && \
 git -C $REPOSITORY remote add origin \
  https://$VCS_PAT@github.com/$REPOSITORY_OWNER/$REPOSITORY_NAME.git && \
 git -C $REPOSITORY fetch --depth=1 origin gh-pages && \
 git -C $REPOSITORY checkout gh-pages || exit 1 # todo

RELATIVE_PATH=$GITHUB_RUN_NUMBER/$GITHUB_RUN_ID/diagnostics/report
mkdir -p $REPOSITORY/build/$RELATIVE_PATH || exit 1 # todo
cp -r diagnostics/report/* $REPOSITORY/build/$RELATIVE_PATH || exit 1 # todo

COMMIT_MESSAGE="CI build #$GITHUB_RUN_NUMBER | $WORKER_NAME added diagnostics report"

TYPES="$(jq -Mcer "keys" diagnostics/summary.json)" || exit 1 # todo
if test "$TYPES" == "[]"; then
 echo "Diagnostics should have determined the cause of the failure!"; exit 1
fi
COMMIT_MESSAGE="${COMMIT_MESSAGE} of ${TYPES} issues."

CODE=0
git -C $REPOSITORY config user.name "$WORKER_NAME" && \
 git -C $REPOSITORY config user.email "$WORKER_VCS_EMAIL"; CODE=$?
if test $CODE -ne 0; then
 echo "Git config failed!"; exit 41
fi

git -C $REPOSITORY add --all . && \
 git -C $REPOSITORY commit -m "$COMMIT_MESSAGE" && \
 git -C $REPOSITORY tag "diagnostics/report/$GITHUB_RUN_NUMBER/$GITHUB_RUN_ID"; CODE=$?
if test $CODE -ne 0; then
 echo "Git commit failed!"; exit 42
fi

git -C $REPOSITORY push && \
 git -C $REPOSITORY push --tag; CODE=$?
if test $CODE -ne 0; then
 echo "Git push failed!"; exit 43
fi

exit 0
