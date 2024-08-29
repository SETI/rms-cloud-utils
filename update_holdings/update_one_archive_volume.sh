#!/usr/bin/bash
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
    gsutil ls gs://rms-node-holdings/pds3-holdings/archives-${TYPE}/${VOLSET}/${ARCHIVE_FILE} > /dev/null 2>&1
    if [ $? == 0 ]; then
        echo Skipping ${TYPE}/${VOLSET}/${ARCHIVE_FILE} because archive file already exists
        exit 0
    fi
    set -e
fi

echo "** gsutil cp gs://rms-node/holdings/archives-${TYPE}/${VOLSET}/${ARCHIVE_FILE} ."
gsutil cp gs://rms-node/holdings/archives-${TYPE}/${VOLSET}/${ARCHIVE_FILE} .
if [ $? -ne 0 ]; then
    echo "FAIL: gsutil cp gs://rms-node/holdings/archives-${TYPE}/${VOLSET}/${ARCHIVE_FILE} ."
    rm -f ${ARCHIVE_FILE}
    rm -rf ${VOLUME}
    exit 1
fi
tar xf ${ARCHIVE_FILE}
if [ $? -ne 0 ]; then
    echo "FAIL: tar xf ${ARCHIVE_FILE}"
    rm -f ${ARCHIVE_FILE}
    rm -rf ${VOLUME}
    exit 1
fi
gsutil cp ${ARCHIVE_FILE} gs://rms-node-holdings/pds3-holdings/archives-${TYPE}/${VOLSET}/${ARCHIVE_FILE}
if [ $? -ne 0 ]; then
    echo "FAIL: gsutil cp ${ARCHIVE_FILE} gs://rms-node-holdings/pds3-holdings/archives-${TYPE}/${VOLSET}/${ARCHIVE_FILE}"
    rm -f ${ARCHIVE_FILE}
    rm -rf ${VOLUME}
    exit 1
fi
gsutil -m rsync -r ${VOLUME} gs://rms-node-holdings/pds3-holdings/${TYPE}/${VOLSET}/${VOLUME}
if [ $? -ne 0 ]; then
    echo "FAIL: gsutil -m rsync -r ${VOLUME} gs://rms-node-holdings/pds3-holdings/${TYPE}/${VOLSET}/${VOLUME}"
    rm -f ${ARCHIVE_FILE}
    rm -rf ${VOLUME}
    exit 1
fi
rm ${ARCHIVE_FILE}
rm -rf ${VOLUME}

echo "SUCCESS"
