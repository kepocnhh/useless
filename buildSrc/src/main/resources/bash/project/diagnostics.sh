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
  cp -r repository/$(jq -Mcer ".${TYPE}.report" $ENVIRONMENT) diagnostics/report/$TYPE || exit 1 # todo
  echo "$(jq -cM ".types+=[\"$TYPE\"]" diagnostics/summary.json)" > diagnostics/summary.json || exit $((100+i))
 fi
done

ENVIRONMENT=repository/buildSrc/src/main/resources/json/code_quality.json
ARRAY=(main test)
SIZE=${#ARRAY[*]}
for ((i=0; i<SIZE; i++)); do
 TYPE="CODE_QUALITY.${ARRAY[i]}"
 TASK="$(jq -Mcer ".${TYPE}.task" $ENVIRONMENT)" || exit 1 # todo
 gradle -p repository "$TASK"; CODE=$?
 if test $CODE -ne 0; then
  cp -r repository/$(jq -Mcer ".${TYPE}.report" $ENVIRONMENT) diagnostics/report/$TYPE || exit 1 # todo
  echo "$(jq -cM ".types+=[\"$TYPE\"]" diagnostics/summary.json)" > diagnostics/summary.json || exit $((300+i))
 fi
done

ENVIRONMENT=repository/buildSrc/src/main/resources/json/unit_test.json
TYPE="UNIT_TEST"
gradle -p repository "$(jq -Mcer ".${TYPE}.task" $ENVIRONMENT)"; CODE=$?
if test $CODE -ne 0; then
 cp -r repository/$(jq -Mcer ".${TYPE}.report" $ENVIRONMENT) diagnostics/report/$TYPE || exit 1 # todo
 echo "$(jq -cM ".types+=[\"$TYPE\"]" diagnostics/summary.json)" > diagnostics/summary.json || exit $((100+i))
else
 TYPE="${TYPE}.coverage"
 gradle -p repository "$(jq -Mcer ".${TYPE}.task" $ENVIRONMENT)" || exit 1 # todo
 gradle -p repository "$(jq -Mcer ".${TYPE}.verification.task" $ENVIRONMENT)"; CODE=$?
 if test $CODE -ne 0; then
  cp -r repository/$(jq -Mcer ".${TYPE}.report" $ENVIRONMENT) diagnostics/report/$TYPE || exit 1 # todo
  echo "$(jq -cM ".types+=[\"$TYPE\"]" diagnostics/summary.json)" > diagnostics/summary.json || exit $((100+i))
 fi
fi

TYPES="$(jq -Mcer .types diagnostics/summary.json)" || exit 1 # todo
if test "$TYPES" == "[]"; then
 echo "Diagnostics should have determined the cause of the failure!"; exit 1
fi

echo "Diagnostics have determined the cause of the failure - this is: $TYPES."

exit 0
