#!/bin/bash

echo "Workflow pull request unstable start..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

mkdir -p assemble/vcs
/bin/bash $SCRIPTS/assemble/vcs/repository.sh || exit 11
/bin/bash $SCRIPTS/assemble/vcs/worker.sh || exit 12
/bin/bash $SCRIPTS/assemble/vcs/pr.sh || exit 13

/bin/bash $SCRIPTS/vcs/pr/merge.sh || exit 21
/bin/bash $SCRIPTS/vcs/pr/commit.sh || exit 22

exit 1 # todo

exit 0
