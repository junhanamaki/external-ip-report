#!/bin/bash

DEFAULT_SERVICE_ADDRESS="http://myexternalip.com/raw"
GET_EXTERNAL_IP_ERROR_LIMIT=3
ERROR_COUNT_FILENAME="error_count"
CURRENT_IP_FILENAME="current_ip"

error_exit () {
    echo $1 >&2
    exit ${2:-1}
}

if [ -z "$1" ]; then
  SERVICE_ADRESS=$DEFAULT_SERVICE_ADDRESS
else
  SERVICE_ADRESS=$1
fi

# get current external ip
CURRENT_IP=$(curl $SERVICE_ADRESS 2>/dev/null)

# check if we failed to get ip
if [ -z "$CURRENT_IP" ]; then
  # get error count
  GET_EXTERNAL_IP_ERROR_COUNT=$(cat $ERROR_COUNT_FILENAME 2>/dev/null)

  # check if present, if not set to 0
  if [ -z "$GET_EXTERNAL_IP_ERROR_COUNT" ]; then
    GET_EXTERNAL_IP_ERROR_COUNT=0
  fi

  if [ $GET_EXTERNAL_IP_ERROR_COUNT -gt $GET_EXTERNAL_IP_ERROR_LIMIT ]; then
    error_exit "Error: Failed to get external ip more than $GET_EXTERNAL_IP_ERROR_LIMIT times"
  else
    echo $(($GET_EXTERNAL_IP_ERROR_COUNT + 1)) > $ERROR_COUNT_FILENAME
    exit 0
  fi
else
  # reset error count
  echo 0 > $ERROR_COUNT_FILENAME
fi

# get previous ip
PREVIOUS_IP=$(cat current_ip 2>/dev/null)

if [ "$PREVIOUS_IP" = "$CURRENT_IP" ]; then
  # nothing to do, exit
  exit 0
else
  # save new ip
  echo $CURRENT_IP > $CURRENT_IP_FILENAME

  # output message
  echo "Hello. My networks external ip has changed and is now $CURRENT_IP, have a nice day!"

  exit 0
fi
