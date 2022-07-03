#!/bin/bash

echo "Project pre verify..."

SCRIPTS=repository/buildSrc/src/main/resources/bash

REPOSITORY=repository
. $SCRIPTS/util/assert -d $REPOSITORY

gradle -p $REPOSITORY verifyService \
 || . $SCRIPTS/util/throw 11 "Gradle verify service error!"

exit 0
