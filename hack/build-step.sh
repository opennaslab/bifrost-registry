#!/bin/env bash

set -o errexit

function usage() {
    echo "This script is used to parse step."
    echo "Usage: hack/build-step.sh $file $cache_file"
    echo "Example: hack/build-step.sh steps/frpc-config/Dockerfile /tmp/step-cache"
}

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

change_file_path=$1
cache_file=$2

function parse_step_name() {
    file_path=$1
    if [[ "$file_path" =~ ^steps* ]]; then
        step_name=$(echo $1 | cut -d '/' -f 2)
        echo "$step_name"
    else
        echo ""
    fi
}

step_name=$(parse_step_name $change_file_path)
if [ -z "$step_name" ]; then
    exit 0
fi
build_step=$(cat $cache_file)
if [[ "$build_step" =~ "$step_name" ]]; then
    exit 0
fi

echo "$step_name" >> $cache_file

docker build -t opennaslab/$step_name:latest steps/$step_name
docker push opennaslab/$step_name:latest
