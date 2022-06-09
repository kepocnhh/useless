#!/bin/bash

echo "Workflow pull request unstable start..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

mkdir -p assemble/vcs
/bin/bash $SCRIPTS/assemble/vcs/repository.sh || exit 11
/bin/bash $SCRIPTS/assemble/vcs/worker.sh || exit 12
/bin/bash $SCRIPTS/assemble/vcs/pr.sh || exit 13
/bin/bash $SCRIPTS/assemble/vcs/pr/commit.sh || exit 13

/bin/bash $SCRIPTS/vcs/pr/merge.sh || exit 21

mkdir -p assemble/project
/bin/bash $SCRIPTS/project/prepare.sh || exit 31
/bin/bash $SCRIPTS/assemble/project/common.sh || exit 32

/bin/bash $SCRIPTS/workflow/pr/unstable/vcs/tag/test.sh || exit 41
/bin/bash $SCRIPTS/workflow/pr/unstable/vcs/push.sh || exit 42
/bin/bash $SCRIPTS/workflow/pr/unstable/vcs/release.sh || exit 43
/bin/bash $SCRIPTS/vcs/pr/check_state.sh "closed" || exit 44

/bin/bash $SCRIPTS/workflow/pr/unstable/on_success.sh || exit 91

echo "Workflow pull request unstable finish."

exit 0
