#!/usr/bin/bash
set -e

if [ $# != 1 ] && [ $# != 2 ]; then
    echo "Usage: update_all_one_type.sh <type> [--force | --force-expanded]"
    exit -1
fi

if [ $# == 2 ] && [ "$2" != "--force" ]; then
    echo "Usage: update_all_one_type.sh <type> [--force | --force-expanded]"
    exit -1
fi

TYPE=$1
FORCE=$2

echo "** Updating all volsets of type ${TYPE}"

for VOLSET_PATH in $(gsutil ls gs://rms-node/holdings/archives-${TYPE}); do
    VOLSET=$(basename ${VOLSET_PATH})
    echo Updating volset ${TYPE}/${VOLSET}
    ./update_one_archive_volset.sh ${TYPE} ${VOLSET} ${FORCE}
done
