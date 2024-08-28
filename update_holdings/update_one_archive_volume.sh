#!/usr/bin/bash
set -e

if [[ $# -ne 3 ]]; then
    echo "Usage: update_one_archive_volume.sh <type> <volset> <volume>"
    exit -1
fi

TYPE=$1
VOLSET=$2
VOLUME=$3

SUFFIX=
if [[ $TYPE != "volumes" ]]; then
    SUFFIX=_$TYPE
fi

ARCHIVE_FILE=${VOLUME}${SUFFIX}.tar.gz

gsutil cp gs://rms-node/holdings/archives-${TYPE}/${VOLSET}/${ARCHIVE_FILE} .
tar xf ${ARCHIVE_FILE}
gsutil cp ${ARCHIVE_FILE} gs://rms-node-holdings/pds3-holdings/archives-${TYPE}/${VOLSET}/${ARCHIVE_FILE}
gsutil -m rsync -r ${VOLUME} gs://rms-node-holdings/pds3-holdings/${TYPE}/${VOLSET}/${VOLUME}
rm ${ARCHIVE_FILE}
rm -rf ${VOLUME}

