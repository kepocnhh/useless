#!/bin/bash

echo "Workflow pull request assemble vcs..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

mkdir -p assemble/vcs
/bin/bash $SCRIPTS/assemble/vcs/repository.sh || exit 11
/bin/bash $SCRIPTS/assemble/vcs/worker.sh || exit 12
/bin/bash $SCRIPTS/assemble/vcs/pr.sh || exit 13
/bin/bash $SCRIPTS/assemble/vcs/pr/commit.sh || exit 14

exit 0
