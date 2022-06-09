#!/bin/bash

echo "Workflow pull request unstable VCS tag test on failed..."

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))"

VERSION_NAME="$(jq -Mcer ".version.name|$REQUIRE_FILLED_STRING" assemble/project/common.json)" || exit 1 # todo
TAG="${VERSION_NAME}-UNSTABLE"

# todo close pr
# todo comment pr
# todo message telegram

exit 3 # todo

exit 0
