#!/bin/bash

echo "Workflow pull request staging start..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

/bin/bash $SCRIPTS/workflow/pr/assemble/vcs.sh || exit 11

/bin/bash $SCRIPTS/vcs/pr/merge.sh || exit 21

mkdir -p assemble/project
/bin/bash $SCRIPTS/project/prepare.sh || exit 31
/bin/bash $SCRIPTS/assemble/project/common.sh || exit 32

/bin/bash $SCRIPTS/workflow/pr/staging/vcs/tag/test.sh || exit 41
/bin/bash $SCRIPTS/workflow/pr/staging/verify.sh || exit 51 # todo
/bin/bash $SCRIPTS/workflow/pr/staging/task/management.sh || exit 61 # todo
/bin/bash $SCRIPTS/workflow/pr/staging/vcs/push.sh || exit 42
/bin/bash $SCRIPTS/workflow/pr/check_state.sh "closed" || exit 44

/bin/bash $SCRIPTS/workflow/pr/staging/on_success.sh || exit 91

echo "Workflow pull request staging finish."

exit 0
