#!/usr/bin/env sh
EDITOR=vis

modem() {
	mmcli -L | grep -o "Modem/[0-9]" | grep -o [0-9]$
}

editmsg() {
	TMP="$(mktemp --suffix $1_msg)"
	echo "$2" > "$TMP"
	TEXT="$(st -e $EDITOR $TMP)"
	cat $TMP
}

sendmsg() {
	MODEM=$(modem)
	SMSNO=$(
		sudo mmcli -m $MODEM --messaging-create-sms="text='$2',number=$1" |
		grep -o [0-9]*$
	)
	sudo mmcli -s ${SMSNO} --send
	for i in $(mmcli -m $MODEM --messaging-list-sms | grep " (sent)" | cut -f5 -d' ') ; do
	  sudo mmcli -m $MODEM --messaging-delete-sms=$i
	done
}

main() {
	modem || st -e "echo Couldn't determine modem number - is modem online?"

	# Prompt for number
	NUMBER=$(
		echo -e "Enter Number: \nCancel" | 
		dmenu -p "Number" -fn "Terminus-20" -l 10 -c
	)
	echo "$NUMBER" | grep -E "^Cancel$" && exit 1

	# Compose first version of msg
	TEXT="$(editmsg $NUMBER 'Enter text message here')"

	while true
	do
		CHARS=$(echo "$TEXT" | wc -c)
		CONFIRM=$(
			echo -e "Message ($CHARS) to -> $NUMBER: ($TEXT)\nEdit\nSend\nCancel" |
			dmenu -c -idx 1 -p "Confirm" -fn "Terminus-20" -l 10
		)
		echo "$CONFIRM" | grep -E "^Send$" && sendmsg "$NUMBER" "$TEXT" && exit 0
		echo "$CONFIRM" | grep -E "^Cancel$" && exit 1
		echo "$CONFIRM" | grep -E "^Edit$" && TEXT="$(editmsg "$NUMBER" "$TEXT")"
	done
}

main
