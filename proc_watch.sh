#!/bin/sh
SCRIPT_DIR=$(cd $(dirname $0); pwd)
. ${SCRIPT_DIR}/cw_config.sh

###
# Post message to Chatwork Room
# $1 - API KEY
# $2 - ルームID
# $3 - メッセージ
###
function chatworkSendMessage() {
  local api_key=$1
  local room_id=$2
  local message=$3

  curl -X POST -H "X-ChatWorkToken: ${api_key}" \
    --data-urlencode "body=${message}" \
    "https://api.chatwork.com/v2/rooms/${room_id}/messages"
}

if [ $# -ne 1 ]; then
  echo "Usage: $0 process_name" 1>&2
  exit 1
fi

PROCESS_NAME=$1
CHATWORK_MESSAGE_HEADER="[info][title][${HOSTNAME}] ${PROCEES_NAME} watch :o[/title]"
CHATWORK_MESSAGE_MESSAGE="Process Not Found!! process_name: ${PROCESS_NAME}"

COUNT=`ps -ef | grep ${PROCESS_NAME} | grep -v grep | grep -v $0 | wc -l`
if [ ${COUNT} = 0 ]; then
  chatworkSendMessage ${CHATWORK_APP_TOKEN} ${CHATWORK_ROOM_ID} "${CHATWORK_MESSAGE_HEADER}${CHATWORK_MESSAGE_MESSAGE}${CHATWORK_MESSAGE_FOOTER}"
fi