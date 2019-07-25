#!/usr/bin/env bash
# Script to build a local docker image

SCRIPTNAME="$(realpath $0)"
SCRIPTPATH="$(dirname $SCRIPTNAME)"

# `name` and `version` configured from here
source ${SCRIPTPATH}/../.info

docker build -t ${name}:${version} "${SCRIPTPATH}/.." \
  --build-arg user=${USER} \
  --build-arg kernel_ver=${kernel_ver}
