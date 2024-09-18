#!/usr/bin/bash
set -e

if [ $# != 2 ] && [ $# != 3 ]; then
    echo "Usage: update_one_archive_volset.sh <type> <volset> [--force | --force-expanded]"
    exit -1
fi

if [ $# == 3 ] && [ "$3" != "--force" ] && [ "$3" != "--force-expanded" ]; then
    echo "Usage: update_one_archive_volset.sh <type> <volset> [--force | --force-expanded]"
    exit -1
fi

TYPE=$1
VOLSET=$2
FORCE=$3

SUFFIX=
if [[ $TYPE != "volumes" ]]; then
    SUFFIX=_$TYPE
fi

TARGZ=${SUFFIX}.tar.gz

echo "** Updating all volumes of type ${TYPE} in volset ${VOLSET}"

mkdir -p logs

for ARCHIVE_PATH in $(gsutil -u rms-node-419806 ls gs://rms-node-holdings/pds3-holdings/archives-${TYPE}/${VOLSET}); do
    ARCHIVE_FILE=$(basename ${ARCHIVE_PATH})
    VOLUME=${ARCHIVE_FILE%"${TARGZ}"}
    echo Updating volume ${TYPE}/${VOLSET}/${VOLUME}
    ./update_one_archive_volume.sh ${TYPE} ${VOLSET} ${VOLUME} ${FORCE} > logs/${TYPE}_${VOLSET}_${VOLUME} 2>&1 &
done
