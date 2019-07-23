#!/usr/bin/env bash
set -eo pipefail

COMMAND=$1
FILEPATH=$2
FILESIZE=$3
USER_ID=$(whoami)

FILENAME=$(basename -- "${FILEPATH}")

cryptoluks_mountpoint="${HOME}/cryptoluks/${FILENAME}"

function finish() {
  rmdir ${cryptoluks_mountpoint}
}
#trap finish SIGTERM

function usage() {
  echo "Usage: ./cryptoluks.sh command [args ...]"
  echo "  ./cryptoluks.sh create some_name size_in_MB (at least 10 MB)"
  echo "  ./cryptoluks.sh open some_name"
  echo -e "  ./cryptoluks.sh close some_name\n"
}

function cryptoluks_mount() {
  [[ -d "${cryptoluks_mountpoint}" ]] || mkdir -p "${cryptoluks_mountpoint}"
  sudo mount -t ext4 "/dev/mapper/${FILENAME}" "${cryptoluks_mountpoint}" \
  && echo -e "Mount successful\n"
}

function cryptoluks_luksopen() {
  #sudo cryptsetup status ${FILENAME}
  sudo cryptsetup luksOpen "${FILENAME}" "${FILENAME}" \
  && echo -e "luksOpen successful\n"
}

# No command? Show help
if [ "$#" -lt 2 ]; then
  usage
else
  # Accept command
  echo "Command: ${COMMAND}"
  if [ "${COMMAND}" = "create" ]; then
    if [ "$#" -lt 3 ]; then
      usage
      exit
    fi

    # Create
    # Accept filename, size of file in gigabytes, filesystem
    sudo dd if=/dev/zero bs=1M count="${FILESIZE}" of="${FILENAME}" >& /dev/null \
    && sudo cryptsetup luksFormat "${FILENAME}" \
    && echo -e "Preparing ${FILENAME} for LUKS\n"

    cryptoluks_luksopen

    echo "Writing ext4 filesystem to ${FILENAME}"
    sudo mkfs.ext4 "/dev/mapper/${FILENAME}" >& /dev/null

    cryptoluks_mount

    echo "Done!"
    sudo chown $USER_ID.$USER_ID -R ${cryptoluks_mountpoint}
  elif [ "${COMMAND}" = "open" ]; then
    # Open
    cryptoluks_luksopen
    cryptoluks_mount
  elif [ "${COMMAND}" = "close" ]; then
    # Close
    sudo umount "${cryptoluks_mountpoint}" \
    && sudo cryptsetup luksClose "${FILENAME}" \
    && echo -e "Unmounted and closed ${FILENAME} \n"
    sudo rmdir "${cryptoluks_mountpoint}"
  else
    usage
  fi
fi
