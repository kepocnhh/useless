#!/bin/bash

echo "Assemble project common..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

. $SCRIPTS/util/require REPOSITORY_OWNER REPOSITORY_NAME

gradle -p repository saveCommonInfo \
 || . $SCRIPTS/util/throw 11 "Save common info error $?!"

JSON_FILE=$(pwd)/repository/build/common.json
. $SCRIPTS/util/assert -f $JSON_FILE
cp $JSON_FILE assemble/project/common.json

ACTUAL_OWNER=$($SCRIPTS/util/jqx -sfs assemble/project/common.json .repository.owner) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
. $SCRIPTS/util/assert -eq REPOSITORY_OWNER ACTUAL_OWNER

ACTUAL_NAME=$($SCRIPTS/util/jqx -sfs assemble/project/common.json .repository.name) \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
. $SCRIPTS/util/assert -eq REPOSITORY_NAME ACTUAL_NAME

exit 0
