#!/bin/bash

echo "Project prepare..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

gradle -p repository clean \
 || . $SCRIPTS/util/throw 11 "Gradle clean error!"

gradle -p repository lib:compileKotlin \
 || . $SCRIPTS/util/throw 12 "Gradle compile error!"

exit 0
