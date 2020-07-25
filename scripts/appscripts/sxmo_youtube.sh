#!/usr/bin/env sh
menu() {
	pidof "$KEYBOARD" || "$KEYBOARD" &
	SEARCHTERMS="$(
		echo "Close Menu" |
		dmenu -p "Yt Search" -c -l 10 -fn Terminus-20
	)"
	pkill "$KEYBOARD"
	[ "Close Menu" = "$SEARCHTERMS" ] && exit 0

	IDIOTRESULTS="$(youtube-cli "$SEARCHTERMS")"
	FMTRESULTS="$(
		echo "$IDIOTRESULTS" |
		grep -Ev '^(Channelid|Atom feed|Channel title|Published|Viewcount|Userid):' |
		sed -E 's/^(URL|Duration):\s+/\t/g' |
		tr -d '\n' |
		sed 's/===/\n/g' |
		gawk -F'\t' '{ print $3 " " $1 " " $2}'
	)"

	PICKED="$(
		printf %b "Close Menu\n$FMTRESULTS" |
		dmenu -c -l 10 -fn Terminus-20
	)"
	[ "Close Menu" = "$PICKED" ] && exit 0

	URL="$(echo "$PICKED" | awk -F " " '{print $NF}')"
}

video() {
	menu
	st -e mpv -ao=alsa -v --ytdl-format='[height<420]' "$URL"
}

audio() {
	menu
	st -e mpv -ao=alsa -v --no-video "$URL"
}

$1
