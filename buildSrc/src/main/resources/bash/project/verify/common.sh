#!/bin/bash

echo "Project verify..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

if test $# -ne 1; then
 echo "Script needs for 1 argument but actual $#"; exit 11
fi

ENVIRONMENT="$1"

ARRAY=($(jq -Mcer "keys|.[]" $ENVIRONMENT))
SIZE=${#ARRAY[*]}
for ((i=0; i<SIZE; i++)); do
 TYPE="${ARRAY[i]}"
 TASK="$(jq -Mcer ".${TYPE}.task" $ENVIRONMENT)" || exit 1 # todo
 gradle -p repository "$TASK" \
  || . $SCRIPTS/util/throw $((100+i)) "Gradle $TASK error!"
done

exit 0
