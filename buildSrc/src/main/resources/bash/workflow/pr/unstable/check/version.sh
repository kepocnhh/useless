#!/bin/bash

echo "Workflow pull request unstable check version..."

REQUIRE_FILLED_STRING="select((.!=null)and(type==\"string\")and(.!=\"\"))"

VERSION_NAME="$(jq -Mcer ".version.name|$REQUIRE_FILLED_STRING" assemble/project/common.json)"

/bin/bash repository/buildSrc/src/main/resources/bash/vcs/tag/test.sh "${VERSION_NAME}-UNSTABLE" || exit 11

exit 0
