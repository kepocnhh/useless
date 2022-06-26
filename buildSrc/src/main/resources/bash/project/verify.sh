#!/bin/bash

echo "Project verify..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

gradle -p repository verifyService \
 || . $SCRIPTS/util/throw 11 "Gradle verify service error!"

ENVIRONMENT=repository/buildSrc/src/main/resources/json/verify.json
ARRAY=($(jq -Mcer "keys|.[]" $ENVIRONMENT))
SIZE=${#ARRAY[*]}
for ((i=0; i<SIZE; i++)); do
 TYPE="${ARRAY[i]}"
 TASK="$(jq -Mcer ".${TYPE}.task" $ENVIRONMENT)" || exit 1 # todo
 gradle -p repository "$TASK" \
  || . $SCRIPTS/util/throw $((100+i)) "Gradle $TASK error!"
done

CODE=0

ENVIRONMENT=repository/buildSrc/src/main/resources/json/unit_test.json
TYPE="UNIT_TEST"
TASK=$($SCRIPTS/util/jqx -sfs $ENVIRONMENT ".${TYPE}.task") \
 || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
gradle -p repository "$TASK"; CODE=$?
if test $CODE -ne 0; then
 echo "Unit test error!"; exit 121
else
 TYPE="TEST_COVERAGE"
 TASK=$($SCRIPTS/util/jqx -sfs $ENVIRONMENT ".${TYPE}.task") \
  || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
 gradle -p repository "$TASK" || exit 1 # todo
 TASK=$($SCRIPTS/util/jqx -sfs $ENVIRONMENT ".${TYPE}.verification.task") \
  || . $SCRIPTS/util/throw $? "$(cat /tmp/jqx.o)"
 gradle -p repository "$TASK" \
  || . $SCRIPTS/util/throw 122 "Test coverage verification error!"
fi

exit 0
