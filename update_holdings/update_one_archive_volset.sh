#!/usr/bin/bash
set -e

if [[ $# -ne 2 ]]; then
    echo "Usage: update_one_archive_volset.sh <type> <volset>"
    exit -1
fi

TYPE=$1
VOLSET=$2

SUFFIX=
if [[ $TYPE != "volumes" ]]; then
    SUFFIX=_$TYPE
fi

TARGZ=${SUFFIX}.tar.gz

echo "** Updating all volumes of type ${TYPE} in volset ${VOLSET}"

mkdir -p logs

for ARCHIVE_PATH in $(gsutil ls gs://rms-node/holdings/archives-${TYPE}/${VOLSET}); do
    ARCHIVE_FILE=$(basename ${ARCHIVE_PATH})
    VOLUME=${ARCHIVE_FILE%"${TARGZ}"}
    echo Updating volume ${TYPE}/${VOLSET}/${VOLUME}
    ./update_one_archive_volume.sh ${TYPE} ${VOLSET} ${VOLUME} > logs/${TYPE}_${VOLSET}_${VOLUME} 2>&1
done
