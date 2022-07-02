#!/bin/bash

echo "VCS release note report..."

if test $# -ne 1; then
 echo "Script needs for 1 argument but actual $#"; exit 11
fi

TAG="$1"

SCRIPTS=repository/buildSrc/src/main/resources/bash

. $SCRIPTS/util/require VCS_PAT REPOSITORY_OWNER REPOSITORY_NAME GITHUB_RUN_NUMBER GITHUB_RUN_ID TAG

WORKER_NAME=$($SCRIPTS/util/jqx -sfs assemble/vcs/worker.json .name) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
WORKER_VCS_EMAIL=$($SCRIPTS/util/jqx -sfs assemble/vcs/worker.json .vcs_email) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"

REPOSITORY=pages/release/note
mkdir -p $REPOSITORY || exit 1 # todo

git -C $REPOSITORY init \
 && git -C $REPOSITORY remote add origin \
  https://$VCS_PAT@github.com/$REPOSITORY_OWNER/$REPOSITORY_NAME.git \
 && git -C $REPOSITORY fetch --depth=1 origin gh-pages \
 && git -C $REPOSITORY checkout gh-pages \
 || . $SCRIPTS/util/throw 11 "Git checkout error!"

RELATIVE_PATH=$GITHUB_RUN_NUMBER/$GITHUB_RUN_ID/release/note
mkdir -p $REPOSITORY/build/$RELATIVE_PATH || exit 1 # todo
cp assemble/github/release_note.html $REPOSITORY/build/$RELATIVE_PATH/index.html || exit 1 # todo

COMMIT_MESSAGE="CI build #$GITHUB_RUN_NUMBER | $WORKER_NAME added release note $TAG"

git -C $REPOSITORY config user.name "$WORKER_NAME" \
 && git -C $REPOSITORY config user.email "$WORKER_VCS_EMAIL" \
 || . $SCRIPTS/util/throw 41 "Git config error!"

git -C $REPOSITORY add --all . \
 && git -C $REPOSITORY commit -m "$COMMIT_MESSAGE" \
 && git -C $REPOSITORY tag "release/note/$GITHUB_RUN_NUMBER/$GITHUB_RUN_ID" \
 || . $SCRIPTS/util/throw 42 "Git commit error!"

git -C $REPOSITORY push \
 && git -C $REPOSITORY push --tag \
 || . $SCRIPTS/util/throw 43 "Git push error!"

exit 0
