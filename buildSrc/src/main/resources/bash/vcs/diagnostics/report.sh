#!/bin/bash

echo "VCS diagnostics report..."

WORKER_NAME="$(jq -r .name assemble/vcs/worker.json)"
WORKER_EMAIL="$(jq -r .email assemble/vcs/worker.json)"

for it in VCS_PAT REPOSITORY_OWNER REPOSITORY_NAME \
 GITHUB_RUN_NUMBER GITHUB_RUN_ID \
 WORKER_NAME WORKER_EMAIL; do
 if test -z "${!it}"; then echo "$it is empty!"; exit 21; fi; done

REPOSITORY=gh-pages/diagnostics/report
mkdir -p $REPOSITORY || exit 1 # todo

git -C $REPOSITORY init && \
 git -C $REPOSITORY remote add origin \
  https://$VCS_PAT@github.com/$REPOSITORY_OWNER/$REPOSITORY_NAME.git && \
 git -C $REPOSITORY fetch --depth=1 origin gh-pages && \
 git -C $REPOSITORY checkout gh-pages || exit 1 # todo

exit 1 # todo

exit 0
