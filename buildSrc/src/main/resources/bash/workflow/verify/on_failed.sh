#!/bin/bash

echo "Workflow verify on failed start..."

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))"

WORKER_NAME="$(jq -cerM ".name|$REQUIRE_FILLED_STRING" assemble/vcs/worker.json)"
WORKER_VCS_EMAIL="$(jq -cerM ".vcs_email|$REQUIRE_FILLED_STRING" assemble/vcs/worker.json)"

exit 1 # todo

exit 0
