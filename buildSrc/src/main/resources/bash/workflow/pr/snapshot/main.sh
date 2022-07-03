#!/bin/bash

echo "Workflow pull request snapshot start..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

/bin/bash $SCRIPTS/workflow/pr/assemble/vcs.sh || exit 11

/bin/bash $SCRIPTS/vcs/pr/merge.sh || exit 21

mkdir -p assemble/project
/bin/bash $SCRIPTS/project/prepare.sh || exit 31
/bin/bash $SCRIPTS/assemble/project/common.sh || exit 32

/bin/bash $SCRIPTS/workflow/pr/snapshot/vcs/tag/test.sh || exit 81
/bin/bash $SCRIPTS/workflow/pr/snapshot/maven/tag/test.sh || exit 82
/bin/bash $SCRIPTS/workflow/pr/snapshot/verify.sh || exit 51 # todo
/bin/bash $SCRIPTS/workflow/pr/snapshot/task/management.sh || exit 61 # todo

/bin/bash $SCRIPTS/workflow/pr/snapshot/vcs/push.sh || exit 42
/bin/bash $SCRIPTS/workflow/pr/snapshot/maven/release.sh || exit 43
/bin/bash $SCRIPTS/workflow/pr/snapshot/vcs/release.sh || exit 44
/bin/bash $SCRIPTS/workflow/pr/check_state.sh "closed" || exit 71
/bin/bash $SCRIPTS/workflow/pr/snapshot/on_success.sh || exit 91

echo "Workflow pull request snapshot finish."

exit 0
