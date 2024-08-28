#!/usr/bin/bash
set -e

if [ $# != 3 ] && [ $# != 4 ]; then
    echo "Usage: update_one_archive_volume.sh <type> <volset> <volume> [--force]"
    exit -1
fi

if [ $# == 4 ] && [ "$4" != "--force" ]; then
    echo "Usage: update_one_archive_volume.sh <type> <volset> <volume> [--force]"
    exit -1
fi

TYPE=$1
VOLSET=$2
VOLUME=$3
FORCE=$4

SUFFIX=
if [[ $TYPE != "volumes" ]]; then
    SUFFIX=_$TYPE
fi

ARCHIVE_FILE=${VOLUME}${SUFFIX}.tar.gz

if [ -z "$FORCE" ]; then
    set +e
    gsutil ls gs://rms-node-holdings/pds3-holdings/archives-${TYPE}/${VOLSET}/${ARCHIVE_FILE}
    if [ $? == 0 ]; then
        echo Skipping ${TYPE}/${VOLSET}/${ARCHIVE_FILE} because copy already exists
        exit 0
    fi
    set -e
fi

gsutil cp gs://rms-node/holdings/archives-${TYPE}/${VOLSET}/${ARCHIVE_FILE} .
tar xf ${ARCHIVE_FILE}
gsutil cp ${ARCHIVE_FILE} gs://rms-node-holdings/pds3-holdings/archives-${TYPE}/${VOLSET}/${ARCHIVE_FILE}
gsutil -m rsync -r ${VOLUME} gs://rms-node-holdings/pds3-holdings/${TYPE}/${VOLSET}/${VOLUME}
rm ${ARCHIVE_FILE}
rm -rf ${VOLUME}
