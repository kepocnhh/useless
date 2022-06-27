#!/bin/bash

echo "Workflow pull request staging verify..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

CODE=0

/bin/bash $SCRIPTS/project/verify.sh; CODE=$?
if test $CODE -ne 0; then
 mkdir -p diagnostics
 /bin/bash $SCRIPTS/project/diagnostics.sh && \
  /bin/bash $SCRIPTS/vcs/diagnostics/report.sh && \
  /bin/bash $SCRIPTS/workflow/pr/staging/verify/on_failed.sh || exit 1 # todo
 exit 31
fi

exit 0
