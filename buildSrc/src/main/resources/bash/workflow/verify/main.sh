#!/bin/bash

echo "Workflow verify start..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

mkdir -p assemble/vcs
/bin/bash $SCRIPTS/assemble/vcs/repository.sh || exit 11
/bin/bash $SCRIPTS/assemble/vcs/worker.sh || exit 12

mkdir -p assemble/project
/bin/bash $SCRIPTS/project/prepare.sh || exit 21
/bin/bash $SCRIPTS/assemble/project/common.sh || exit 22
/bin/bash $SCRIPTS/project/verify.sh || exit 23

exit 1 # todo

exit 0
