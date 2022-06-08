#!/bin/bash

echo "Project prepare..."

CODE=0

gradle -p repository clean; CODE=$?
if test $CODE -ne 0; then
 echo "Gradle clean error $CODE!"
 exit 11
fi

exit 0
