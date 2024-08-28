#!/usr/bin/bash
set -e

if [[ $# -ne 1 ]]; then
    echo "Usage: update_all_one_type.sh <type>"
    exit -1
fi

TYPE=$1

echo "** Updating all volsets of type ${TYPE}"

for VOLSET_PATH in $(gsutil ls gs://rms-node/holdings/archives-${TYPE}); do
    VOLSET=$(basename ${VOLSET_PATH})
    echo Updating volset ${TYPE}/${VOLSET}
    ./update_one_archive_volset.sh ${TYPE} ${VOLSET}
done
