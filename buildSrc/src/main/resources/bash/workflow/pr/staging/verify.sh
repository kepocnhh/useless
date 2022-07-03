#!/bin/bash

echo "Workflow pull request staging verify..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

/bin/bash $SCRIPTS/project/verify/pre.sh \
 || . $SCRIPTS/util/throw 21 "Pre verify unexpected error!"

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
 /bin/bash $SCRIPTS/workflow/pr/staging/verify/on_failed.sh \
  || . $SCRIPTS/util/throw 12 "On failed unexpected error!"
 exit 31
fi

exit 0
