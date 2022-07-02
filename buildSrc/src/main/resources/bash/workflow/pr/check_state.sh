#!/bin/bash

echo "Workflow pull request check state..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

if test $# -ne 1; then
 echo "Script needs for 1 argument but actual $#"; exit 11
fi

EXPECTED_STATE="$1"

. $SCRIPTS/util/require PR_NUMBER EXPECTED_STATE

for (( i=0; i<10; i++ )); do
 /bin/bash $SCRIPTS/vcs/pr/check_state.sh "$EXPECTED_STATE" && exit 0
 echo "check failed for the $i time..."
 sleep 1
done

echo "The pull request #$PR_NUMBER state is not \"$EXPECTED_STATE\"!"

exit 12
