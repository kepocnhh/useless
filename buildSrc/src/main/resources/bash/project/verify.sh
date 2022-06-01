#!/bin/bash

echo "Project verify..."

CODE=0

gradle -p repository verifyService || exit 1 # todo

ENVIRONMENT=repository/buildSrc/src/main/resources/json/verify.json
ARRAY=($(jq -Mcer ".|keys|.[]" $ENVIRONMENT))
SIZE=${#ARRAY[*]}
for ((i=0; i<SIZE; i++)); do
 TASK="$(jq -Mcer ".${ARRAY[i]}.task" $ENVIRONMENT)" || exit 1 # todo
 gradle -p repository "$TASK"; CODE=$?
 if test $CODE -ne 0; then
  echo "gradle $TASK error"; exit $((100+i))
 fi
done

ENVIRONMENT=repository/buildSrc/src/main/resources/json/unit_test.json
gradle -p repository "$(jq -Mcer ".UNIT_TEST.task" $ENVIRONMENT)"; CODE=$?
if test $CODE -ne 0; then
 echo "Unit test failed!"; exit $((200+i))
else
 gradle -p repository "$(jq -Mcer ".UNIT_TEST.coverage.task" $ENVIRONMENT)" || exit 1 # todo
 gradle -p repository "$(jq -Mcer ".UNIT_TEST.coverage.verification.task" $ENVIRONMENT)"; CODE=$?
 if test $CODE -ne 0; then
  echo "Unit test coverage verification failed!"; exit $((200+i))
 fi
fi

exit 0
