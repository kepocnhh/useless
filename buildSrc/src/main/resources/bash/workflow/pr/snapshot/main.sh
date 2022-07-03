#!/bin/bash

echo "Workflow pull request snapshot start..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

/bin/bash $SCRIPTS/workflow/pr/assemble/vcs.sh || exit 11

/bin/bash $SCRIPTS/vcs/pr/merge.sh || exit 21

mkdir -p assemble/project
/bin/bash $SCRIPTS/project/prepare.sh || exit 31
/bin/bash $SCRIPTS/assemble/project/common.sh || exit 32

/bin/bash $SCRIPTS/workflow/pr/snapshot/vcs/tag/test.sh || exit 41
/bin/bash $SCRIPTS/workflow/pr/snapshot/verify.sh || exit 51 # todo

exit 1 # todo

echo "Workflow pull request snapshot finish."

exit 0
