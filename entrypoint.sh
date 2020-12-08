#!/bin/bash -l

#echo "Hello $1"
#time=$(date)
#echo "::set-output name=time::$time"

set -o nounset;
set -o errexit;
set -o pipefail;

IFS=$'\n\t'

# load the sumolgic config into environment variables
source <( \
  echo "${INPUT_SUMOLOGIC_CONFIG}" | \
  jq -r 'to_entries | .[] | "export " + .key + "=\"" + .value + "\""' \
  )

env | grep SUMO

curl \
  --silent \
  --show-error \
  --user "${SUMOLOGIC_ACCESS_ID}:${SUMOLOGIC_ACCESS_KEY}" \
  -XGET \
  "${SUMOLOGIC_API_ENDPOINT}/v2/content/folders/global"
