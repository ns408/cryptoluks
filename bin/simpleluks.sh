#!/usr/bin/env bash

COMMAND=$1
FILENAME=$2
FILESIZE=$3

cryptoluks_mountpoint="${HOME}/cryptoluks/${FILENAME}"

function usage() {
  echo "Usage: ./simpleluks.sh command [args ...]"
  echo "  ./simpleluks.sh create some_name size_in_GB"
  echo "  ./simpleluks.sh open some_name"
  echo "  ./simpleluks.sh close some_name"
}

function cryptoluks_mount() {
  if [[ -d "${cryptoluks_mountpoint}" ]] ; then
    echo "Creating ${cryptoluks_mountpoint}"
    mkdir -p "${cryptoluks_mountpoint}"
  fi
  echo "Mounting ${FILENAME} to ${cryptoluks_mountpoint}"
  sudo mount -t ext4 "/dev/mapper/${FILENAME}" "${cryptoluks_mountpoint}" \
  && echo "Mount successful"
}

function cryptoluks_luksopen() {
  echo "Opening ${FILENAME} with LUKS"
  sudo cryptsetup luksOpen "${FILENAME}" "${FILENAME}"
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
    echo "Writing zeroes into ${FILENAME}"
    sudo dd if=/dev/zero bs=1G count="${FILESIZE}" of="${FILENAME}"
    echo "Preparing ${FILENAME} for LUKS"
    sudo cryptsetup luksFormat "${FILENAME}"
    cryptoluks_luksopen
    echo "Writing ext4 filesystem to ${FILENAME}"
    sudo mkfs.ext4 "/dev/mapper/${FILENAME}"
    cryptoluks_mount
    echo "Done!"
    #echo "You may want to run sudo chown $USER -R ${cryptoluks_mountpoint}"
  elif [ "${COMMAND}" = "open" ]; then
    # Open
    cryptoluks_luksopen
    cryptoluks_mount
  elif [ "${COMMAND}" = "close" ]; then
    # Close
    sudo umount "${cryptoluks_mountpoint}" \
    && sudo cryptsetup luksClose "${FILENAME}" \
    && echo "Unmounted and closed ${FILENAME}"
  else
    usage
  fi
fi
