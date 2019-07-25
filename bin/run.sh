#!/usr/bin/env bash

SCRIPTNAME="$(realpath $0)"
SCRIPTPATH="$(dirname $SCRIPTNAME)"

# `name` and `version` configured from here
source ${SCRIPTPATH}/../.info

docker run \
  --privileged \
  -v ${SCRIPTPATH}/..:/home/${USER}/app \
  -u ${USER} \
  -it ${name}:${version} /bin/bash \
  ${1}
  #--cap-add=SYS_MODULE \
