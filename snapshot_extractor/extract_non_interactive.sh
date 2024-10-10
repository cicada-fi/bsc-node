#!/bin/bash
set -e
SAVE_PATH=$SAVE_DIR/$SAVE_FILE

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
  rm -rf $SAVE_PATH
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
