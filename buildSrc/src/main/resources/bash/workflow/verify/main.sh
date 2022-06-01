#!/bin/bash

echo "Workflow verify start..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

mkdir -p assemble/vcs
/bin/bash $SCRIPTS/assemble/vcs/repository.sh || exit 11
/bin/bash $SCRIPTS/assemble/vcs/worker.sh || exit 12

mkdir -p assemble/project
/bin/bash $SCRIPTS/project/prepare.sh || exit 21
/bin/bash $SCRIPTS/assemble/project/common.sh || exit 22

CODE=0

/bin/bash $SCRIPTS/project/verify.sh; CODE=$?
if test $CODE -ne 0; then
 mkdir -p diagnostics/report
 /bin/bash $SCRIPTS/project/diagnostics.sh
 exit 1 # todo
 exit 31
fi
exit 1 # todo

exit 0
