#!/bin/sh -l

echo "Hello $1"
time=$(date)
echo "::set-output name=time::$time"

echo "${INPUT_SUMOLOGIC_CONFIG}" | jq -rM '.' | base64 > /tmp/boo
cat /tmp/boo
