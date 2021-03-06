#!/bin/sh
SCRIPT_DIR=$(cd $(dirname $0); pwd)

if [ ! -e ${SCRIPT_DIR}/.env ]; then
  echo ".env not found:("
  exit 1
fi

#if [ $# -ne 1 ]; then
#  echo "Usage: $0 process_name" 1>&2
#  exit 1
#fi

. ${SCRIPT_DIR}/.env

###
# Post message to Chatwork Room
# $1 - API KEY
# $2 - ルームID
# $3 - メッセージ
###
function chatworkSendMessage() {
  local API_KEY=$1
  local ROOM_ID=$2
  local MESSAGE=$3

  curl -X POST -H "X-ChatWorkToken: ${API_KEY}" \
    --data-urlencode "body=${MESSAGE}" \
    "https://api.chatwork.com/v2/rooms/${ROOM_ID}/messages"
}

CHATWORK_MESSAGE_HEADER="[info][title][${HOSTNAME}] ${TARGET_NAME} watch :o[/title]"
CHATWORK_MESSAGE_FOOTER="[/info]"

COUNT=`ps -ef | grep ${TARGET_NAME} | grep -v grep | grep -v $0 | wc -l`
if [ ${COUNT} = 0 -a ! -f ${HOSTNAME}_${TARGET_NAME}_err.log ]; then
  chatworkSendMessage ${CHATWORK_APP_TOKEN} ${CHATWORK_ROOM_ID} "${CHATWORK_MESSAGE_HEADER}Process Not Found!! process_name: ${TARGET_NAME}${CHATWORK_MESSAGE_FOOTER}"
  echo `date '+%y/%m/%d %H:%M:%S'` 2> ${SCRIPT_DIR}/${HOSTNAME}_${TARGET_NAME}_err.log
else
  if [ -e ${SCRIPT_DIR}/${HOSTNAME}_${TARGET_NAME}_err.log ]; then
    rm ${SCRIPT_DIR}/${HOSTNAME}_${TARGET_NAME}_err.log
  fi
  if [[ -z "$TARGET_RECOVERY_COMMAND" ]]; then
    $TARGET_RECOVERY_COMMAND
    chatworkSendMessage ${CHATWORK_APP_TOKEN} ${CHATWORK_ROOM_ID} "${CHATWORK_MESSAGE_HEADER}Process recovered!! process_name: ${TARGET_NAME}${CHATWORK_MESSAGE_FOOTER}"
  fi
fi
