#!/usr/bin/bash
if [ $# != 3 ] && [ $# != 4 ]; then
    echo "Usage: update_one_archive_volume.sh <type> <volset> <volume> [--force]"
    exit -1
fi

if [ $# == 4 ] && [ "$4" != "--force" ] && [ "$4" != "--force-expanded" ]; then
    echo "Usage: update_one_archive_volume.sh <type> <volset> <volume> [--force | --force-expanded]"
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

mkdir -p ${VOLSET}

COPY_ARCHIVE=0

gsutil -u rms-node-419806 cp gs://rms-node-holdings/pds3-holdings/archives-${TYPE}/${VOLSET}/${ARCHIVE_FILE} ${VOLSET}/${ARCHIVE_FILE}
if [ $? -ne 0 ]; then
    echo "FAIL: gsutil cp gs://rms-node-holdings/pds3-holdings/archives-${TYPE}/${VOLSET}/${ARCHIVE_FILE} ${VOLSET}/${ARCHIVE_FILE}"
    rm -f ${VOLSET}/${ARCHIVE_FILE}
    rm -rf ${VOLSET}/${VOLUME}
    exit 1
fi

rm -rf ${VOLSET}/${VOLUME}
echo "** (cd ${VOLSET}; tar xf ${ARCHIVE_FILE})"
(cd ${VOLSET}; tar xf ${ARCHIVE_FILE})
if [ $? -ne 0 ]; then
    echo "FAIL: (cd ${VOLSET}; tar xf ${ARCHIVE_FILE})"
    rm -f ${VOLSET}/${ARCHIVE_FILE}
    rm -rf ${VOLSET}/${VOLUME}
    exit 1
fi
echo "** gsutil -m rsync -r ${VOLSET}/${VOLUME} gs://rms-node-holdings/pds3-holdings/${TYPE}/${VOLSET}/${VOLUME}"
gsutil -u rms-node-419806 -m rsync -r ${VOLSET}/${VOLUME} gs://rms-node-holdings/pds3-holdings/${TYPE}/${VOLSET}/${VOLUME}
if [ $? -ne 0 ]; then
    echo "FAIL: gsutil -m rsync -r ${VOLSET}/${VOLUME} gs://rms-node-holdings/pds3-holdings/${TYPE}/${VOLSET}/${VOLUME}"
    rm -f ${VOLSET}/${ARCHIVE_FILE}
    rm -rf ${VOLSET}/${VOLUME}
    exit 1
fi
rm ${VOLSET}/${ARCHIVE_FILE}
rm -rf ${VOLSET}/${VOLUME}

echo "SUCCESS"
