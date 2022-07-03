#!/bin/bash

echo "Workflow verify start..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

mkdir -p assemble/vcs
/bin/bash $SCRIPTS/assemble/vcs/repository.sh || exit 11
/bin/bash $SCRIPTS/assemble/vcs/worker.sh || exit 12
/bin/bash $SCRIPTS/assemble/vcs/commit.sh || exit 13

mkdir -p assemble/project
/bin/bash $SCRIPTS/project/prepare.sh || exit 21
/bin/bash $SCRIPTS/assemble/project/common.sh || exit 22

CODE=0

JSON_PATH=repository/buildSrc/src/main/resources/json
/bin/bash $SCRIPTS/project/verify/common.sh "$JSON_PATH/verify.json" \
 && /bin/bash $SCRIPTS/project/verify/unit_test.sh; CODE=$?
if test $CODE -ne 0; then
 mkdir -p diagnostics
 echo "{}" > diagnostics/summary.json
 /bin/bash $SCRIPTS/project/diagnostics/common.sh "$JSON_PATH/verify.json" \
  && /bin/bash $SCRIPTS/project/diagnostics/unit_test.sh \
  && /bin/bash $SCRIPTS/vcs/diagnostics/report.sh \
  || . $SCRIPTS/util/throw 11 "Diagnostics unexpected error!"
 /bin/bash $SCRIPTS/workflow/verify/on_failed.sh \
  || . $SCRIPTS/util/throw 12 "On failed unexpected error!"
 exit 31
fi

/bin/bash $SCRIPTS/workflow/verify/on_success.sh || exit 41

echo "Workflow verify finish."

exit 0
