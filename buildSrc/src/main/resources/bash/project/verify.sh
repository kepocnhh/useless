#!/bin/bash

echo "Project verify..."

CODE=0

ARRAY=(CodeStyle License Readme Service)
SIZE=${#ARRAY[*]}
for ((i=0; i<SIZE; i++)); do
 it="${ARRAY[i]}"
 gradle -p repository verify$it; CODE=$?
 if test $CODE -ne 0; then
  echo "gradle verify $it error"; exit $((100+i))
 fi
done

exit 1 # todo

exit 0
