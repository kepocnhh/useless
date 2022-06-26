#!/bin/bash

echo "Notification telegram send file..."

if test $# -ne 1; then
 echo "Script needs for 1 argument but actual $#"; exit 11
fi

FILE_PATH="$1"

for it in TELEGRAM_BOT_ID TELEGRAM_BOT_TOKEN TELEGRAM_CHAT_ID FILE_PATH; do
 if test -z "${!it}"; then echo "$it is empty!"; exit 21; fi; done

CODE=$(curl -w %{http_code} -o /tmp/telegram.o \
 -F document=@"$FILE_PATH" \
 "https://api.telegram.org/bot${TELEGRAM_BOT_ID}:${TELEGRAM_BOT_TOKEN}/sendDocument?chat_id=$TELEGRAM_CHAT_ID")

if test $CODE -ne 200; then
 echo "Send file error!"
 cat /tmp/telegram.o
 echo "Request error with response code $CODE!"
 exit 31
fi

exit 0
