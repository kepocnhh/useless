#!/bin/bash

echo "Project diagnostics..."

echo "{\"types\":[]}" > diagnostics/summary.json

CODE=0

ENVIRONMENT=repository/buildSrc/src/main/resources/json/verify.json
ARRAY=($(jq -Mcer ".|keys|.[]" $ENVIRONMENT))
SIZE=${#ARRAY[*]}
for ((i=0; i<SIZE; i++)); do
 TYPE="${ARRAY[i]}"
 TASK="$(jq -Mcer ".${TYPE}.task" $ENVIRONMENT)" || exit 1 # todo
 gradle -p repository "$TASK"; CODE=$?
 if test $CODE -ne 0; then
  RELATIVE="$(jq -Mcer ".${TYPE}.path" $ENVIRONMENT)" || exit 1 # todo
  mkdir -p diagnostics/report/$RELATIVE
  cp -r repository/$(jq -Mcer ".${TYPE}.report" $ENVIRONMENT)/* diagnostics/report/$RELATIVE || exit 1 # todo
  echo "$(jq -cM ".types+=[\"$TYPE\"]" diagnostics/summary.json)" > diagnostics/summary.json || exit $((100+i))
 fi
done

ENVIRONMENT=repository/buildSrc/src/main/resources/json/unit_test.json
TYPE="UNIT_TEST"
gradle -p repository "$(jq -Mcer ".${TYPE}.task" $ENVIRONMENT)"; CODE=$?
if test $CODE -ne 0; then
 RELATIVE="$(jq -Mcer ".${TYPE}.path" $ENVIRONMENT)" || exit 1 # todo
 mkdir -p diagnostics/report/$RELATIVE
 cp -r repository/$(jq -Mcer ".${TYPE}.report" $ENVIRONMENT)/* diagnostics/report/$RELATIVE || exit 1 # todo
 echo "$(jq -cM ".types+=[\"$TYPE\"]" diagnostics/summary.json)" > diagnostics/summary.json || exit 121
else
 TYPE="${TYPE}.coverage"
 gradle -p repository "$(jq -Mcer ".${TYPE}.task" $ENVIRONMENT)" || exit 1 # todo
 gradle -p repository "$(jq -Mcer ".${TYPE}.verification.task" $ENVIRONMENT)"; CODE=$?
 if test $CODE -ne 0; then
  RELATIVE="$(jq -Mcer ".${TYPE}.path" $ENVIRONMENT)" || exit 1 # todo
  mkdir -p diagnostics/report/$RELATIVE
  cp -r repository/$(jq -Mcer ".${TYPE}.report" $ENVIRONMENT)/* diagnostics/report/$RELATIVE || exit 1 # todo
  echo "$(jq -cM ".types+=[\"$TYPE\"]" diagnostics/summary.json)" > diagnostics/summary.json || exit 122
 fi
fi

TYPES="$(jq -Mcer .types diagnostics/summary.json)" || exit 1 # todo
if test "$TYPES" == "[]"; then
 echo "Diagnostics should have determined the cause of the failure!"; exit 1
fi

echo "Diagnostics have determined the cause of the failure - this is: $TYPES."

exit 0
