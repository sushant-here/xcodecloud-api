#!/bin/bash

ISSUER_ID="${ASC_ISSUER_ID}"
KEY_ID="${ASC_KEY_ID}"
WORKFLOW_NAME=`echo "${ASC_WORKFLOW_NAME}" | sed 's,^ *,,; s, *$,,'`
ASC_API_BASE=https://api.appstoreconnect.apple.com/v1

export TEMPDIR=tmp
rm -rf "${TEMPDIR}"
mkdir "${TEMPDIR}"

# Generate JWT Token
export JWT=`ruby jwt.rb --issuer "${ISSUER_ID}" --keyid "${KEY_ID}"`

# Fetch products
echo 1... =======================================================
echo Fetching products...
curl --silent --location "${ASC_API_BASE}/ciProducts" \
     --header "Authorization: Bearer ${JWT}" > "${TEMPDIR}/ciProducts.json"

echo 2... =======================================================
echo Fetching product build runs...
BUILD_RUNS_URL=`cat "${TEMPDIR}/ciProducts.json" | \
jq -r '.data[].relationships.buildRuns.links.related' | \
head -n 1`

## Here we sort the builds by descending build number. 
curl --silent --location "${BUILD_RUNS_URL}?sort=-number" \
     --header "Authorization: Bearer ${JWT}" > "${TEMPDIR}/ciProducts-buildRuns.json"

echo 3... =======================================================
echo Fetching actions...

cat "${TEMPDIR}"/*-buildRuns.json | \
jq '.data | map(select(.attributes.completionStatus == "SUCCEEDED"))' | \
jq -r '.[0]' > "${TEMPDIR}/last-buildRun.json"

cat ${TEMPDIR}/last-buildRun.json | jq 

ACTIONS_URL=`cat "${TEMPDIR}/last-buildRun.json" | \
jq -r '.relationships.actions.links.related'`

curl --silent --location "${ACTIONS_URL}" \
     --header "Authorization: Bearer ${JWT}" > "${TEMPDIR}/buildRuns-actions.json"

echo 4... =======================================================
echo Fetching artifact list...

ARTIFACTS_URL=`cat "${TEMPDIR}/buildRuns-actions.json" | \
jq '.data[] | select(.attributes.actionType=="ARCHIVE")' | \
jq -r '.relationships.artifacts.links.related'`

curl --silent --location "${ARTIFACTS_URL}" \
     --header "Authorization: Bearer ${JWT}" > "${TEMPDIR}/actions-artifacts.json"

echo 5... =======================================================
echo Fetching artifact export...

EXPORT_ARTIFACT_URL=`cat "${TEMPDIR}/actions-artifacts.json" | \
jq '.data[] | select(.attributes.fileType=="ARCHIVE_EXPORT")' | \
jq 'select(.attributes.fileName|test("app-store"))' | \
jq -r '.links.self'`

curl --silent --location "${EXPORT_ARTIFACT_URL}" \
     --header "Authorization: Bearer ${JWT}" > "${TEMPDIR}/artifacts-export.json"

echo 6... =======================================================
echo Downloading artifact...

DOWNLOAD_URL=`cat "${TEMPDIR}/artifacts-export.json" | \
jq -r '.data.attributes.downloadUrl'`
DOWNLOAD_FILENAME=`cat "${TEMPDIR}/artifacts-export.json" | \
jq -r '.data.attributes.fileName'`

if [[ "$DOWNLOAD_URL" == "null" ]]
then
     echo Unable to read download url.
     exit 99
fi

if [[ "$DOWNLOAD_FILENAME" == "null" ]]
then
     echo Unable to read download file name.
     exit 99
fi

OUTPUT_FILE="${TEMPDIR}/${DOWNLOAD_FILENAME}"
echo Starting download to ${OUTPUT_FILE}
echo ${DOWNLOAD_URL}
curl --location "${DOWNLOAD_URL}" \
     --output "${OUTPUT_FILE}"
echo Download complete