#!/bin/bash

echo "VCS pull request merge..."

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))"

for it in PR_NUMBER; do
 if test -z "${!it}"; then echo "$it is empty!"; exit 11; fi; done

WORKER_NAME="$(jq -Mcer ".name|$REQUIRE_FILLED_STRING" assemble/vcs/worker.json)"
WORKER_VCS_EMAIL="$(jq -Mcer ".vcs_email|$REQUIRE_FILLED_STRING" assemble/vcs/worker.json)"
GIT_BRANCH_DST="$(jq -Mcer ".base.ref|$REQUIRE_FILLED_STRING" assemble/vcs/pr${PR_NUMBER}.json)"
GIT_COMMIT_SRC="$(jq -Mcer ".head.sha|$REQUIRE_FILLED_STRING" assemble/vcs/pr${PR_NUMBER}.json)"

for it in WORKER_NAME WORKER_EMAIL GIT_BRANCH_DST GIT_COMMIT_SRC; do
 if test -z "${!it}"; then echo "$it is empty!"; exit 12; fi; done

REPOSITORY=repository
[[ -d "$REPOSITORY" ]] || exit 1 # todo

CODE=0
git -C $REPOSITORY config user.name "$WORKER_NAME" && \
 git -C $REPOSITORY config user.email "$WORKER_VCS_EMAIL"; CODE=$?
if test $CODE -ne 0; then
 echo "Git config failed!"; exit 41
fi

git -C $REPOSITORY checkout $GIT_BRANCH_DST; CODE=$?
if test $CODE -ne 0; then
 echo "Git checkout to \"$GIT_BRANCH_DST\" error!"; exit 42
fi

git -C $REPOSITORY merge --no-ff --no-commit $GIT_COMMIT_SRC; CODE=$?
if test $CODE -ne 0; then
 echo "Git merge ${GIT_COMMIT_SRC::7} -> \"$GIT_BRANCH_DST\" failed!"; exit 43
fi

exit 0
