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

if [[ "${GITHUB_REPOSITORY}" =~ [^/]+\/gds.clusterconfig.(.*) ]]; then
  CLUSTER="${BASH_REMATCH[1]}"
fi
for FILE in $(find . -type f -name orders -maxdepth 2); do
  SERVICE="$(basename $(dirname $FILE))"
  IFS=' \t' read -r TYPE REPOSITORY <<< \
    "$(grep -e "^\(auto\|docker\)deploy\s" $FILE | tail -n1)"
  if [[ "${TYPE}" == "autodeploy" ]]; then
    true
    # there is a generated ecr repo here
  fi
done
# TODO: get ecr repo tag (latest, sha)
echo "$CLUSTER,$SERVICE,$TYPE,$REPOSITORY"

#curl \
#  --silent \
#  --show-error \
#  --user "${SUMOLOGIC_ACCESS_ID}:${SUMOLOGIC_ACCESS_KEY}" \
#  -XGET \
#  "${SUMOLOGIC_API_ENDPOINT}/v2/content/folders/global"
