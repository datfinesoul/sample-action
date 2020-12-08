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

if [[ -n "${INPUT_CLUSTER:-}" ]]; then
  # override if provided via the action
  CLUSTER="${INPUT_CLUSTER}"
elif [[ "${GITHUB_REPOSITORY}" =~ [^/]+\/gds.clusterconfig.(.*) ]]; then
  # otherwise it has to match the gds clusterconfig repo name syntax
  CLUSTER="${BASH_REMATCH[1]}"
fi


for FILE in $(find . -type f -name orders -maxdepth 2); do
  # service is based on directory name
  SERVICE="$(basename $(dirname $FILE))"

  # parse out the deploy commands we support
  IFS=$' \t' read -r TYPE REPOSITORY <<< \
    "$(grep -e "^\(auto\|docker\)deploy\s" $FILE | tail -n1)"

  if [[ "${TYPE}" == "dockerdeploy" ]]; then
    # eg. github/glg/epi-screamer/gds-migration:latest
    true
  fi

  if [[ "${TYPE}" == "autodeploy" ]]; then
    # eg. git@github.com:glg/log.git#master
    true
    # there is a generated ecr repo here
  fi

  # TODO: get ecr repo tag (latest, sha)
  echo "$CLUSTER,$SERVICE,$TYPE,$REPOSITORY"
done

#curl \
#  --silent \
#  --show-error \
#  --user "${SUMOLOGIC_ACCESS_ID}:${SUMOLOGIC_ACCESS_KEY}" \
#  -XGET \
#  "${SUMOLOGIC_API_ENDPOINT}/v2/content/folders/global"
