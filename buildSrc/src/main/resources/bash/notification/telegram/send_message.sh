#!/bin/bash

echo "Notification telegram send message..."

if test $# -ne 1; then
 echo "Script needs for 1 argument but actual $#"; exit 11
fi

MESSAGE="$1"

for it in TELEGRAM_BOT_ID TELEGRAM_BOT_TOKEN TELEGRAM_CHAT_ID MESSAGE; do
 if test -z "${!it}"; then echo "$it is empty!"; exit 21; fi; done

exit 1 # todo

exit 0
