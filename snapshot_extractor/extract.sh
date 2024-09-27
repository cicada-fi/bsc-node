#!/bin/bash
set -e
SAVE_PATH=$SAVE_DIR/$SAVE_FILE
ACT_DOWNLOAD="1"
ACT_CHECKSUM="1"
ACT_EXTRACT="1"

# Function to ask a yes/no question
ask_yes_no() {
    while true; do
        read -p "$1 (y/n): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Check if the snapshot exists
if [ -f "$SAVE_PATH" ]; then
  echo Snapshot $SAVE_PATH already exists:
  ls -la $SAVE_PATH
  if ask_yes_no "Do you want to continue and overwrite it?"; then
    echo Removing snapshot file
    rm -f $SAVE_PATH
    echo Removed
    ACT_DOWNLOAD="1"
  else
    echo "Keeping the existing file"
    ACT_DOWNLOAD="0"
    if ask_yes_no "Should we re-calculate and verify its hash?"; then
      ACT_CHECKSUM="1"
    else
      ACT_CHECKSUM="0"
    fi
  fi
fi

# Check if the target dir exists
if [ -d "$EXTRACT_DIR/geth" ]; then
  echo Target directory $EXTRACT_DIR/geth already exists:
  du -sh $EXTRACT_DIR/geth
  if ask_yes_no "Do you want to continue and overwrite it?"; then
    ACT_EXTRACT="1"
  else
    echo "We won't extract the archive and WILL keep the target intact."
    ACT_EXTRACT="0"
  fi
fi

if [ "$ACT_DOWNLOAD" == "1" ]; then
  mkdir -p $SAVE_DIR
  echo Start downloading from $DOWNLOAD_URL
  aria2c -s4 -x4 -k1024M $DOWNLOAD_URL -d $SAVE_DIR -o $SAVE_FILE
  echo DOWNLOADED to $SAVE_PATH
fi


if [ "$ACT_CHECKSUM" == "1" ]; then
  echo checking sha256 hash
  CALCULATED_SHA256=$(openssl sha256 $SAVE_PATH)
  echo $CALCULATED_SHA256
  if [[ "$CALCULATED_SHA256" == *"$SHA256"* ]]; then
    echo "SHA256 hashes matched"
  else
    echo "SHA256 mismatch. Exiting"
    exit
  fi
fi

if [ "$ACT_EXTRACT" == "1" ]; then
  mkdir -p $EXTRACT_DIR
  echo cleaning target directory $EXTRACT_DIR
  rm -rf *
  cd $EXTRACT_DIR
  echo extracting to $EXTRACT_DIR
  zstd -cd $SAVE_PATH | tar xf -
  echo Successfully extracted
fi

echo Done
echo Now you can safely remove this container and start the node
