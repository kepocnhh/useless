#!/bin/bash

echo "Workflow verify start..."

mkdir -p assemble/vcs
/bin/bash repository/buildSrc/src/main/resources/bash/assemble/vcs/repository.sh || exit 11
/bin/bash repository/buildSrc/src/main/resources/bash/assemble/vcs/worker.sh || exit 12

exit 1 # todo

exit 0
