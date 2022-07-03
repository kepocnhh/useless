#!/bin/bash

echo "Workflow pull request snapshot start..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

/bin/bash $SCRIPTS/workflow/pr/assemble/vcs.sh || exit 11

/bin/bash $SCRIPTS/vcs/pr/merge.sh || exit 21

mkdir -p assemble/project
/bin/bash $SCRIPTS/project/prepare.sh || exit 31
/bin/bash $SCRIPTS/assemble/project/common.sh || exit 32

exit 1 # todo

echo "Workflow pull request snapshot finish."

exit 0
