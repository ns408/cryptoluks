#!/usr/bin/env bash
# Script to build a local docker image

SCRIPTNAME="$(realpath $0)"
SCRIPTPATH="$(dirname $SCRIPTNAME)"

image_name=cryptoluks

if [[ -z ${1+x} ]]; then
  version="$(cat ${SCRIPTPATH}/../.version)"
else
  version="${1}"
fi

docker build -t ${image_name}:${version} "${SCRIPTPATH}/.."
