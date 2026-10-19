#!/bin/sh
last=""
lasttime=0

wl-paste --watch sh -c '
  content="$(wl-paste --no-newline | head -c 120 | tr "\n" " ")"
  [ -z "$content" ] && exit 0
  notify-send -t 4000 -i edit-paste -h string:x-canonical-private-synchronous:clip \
    "Copied to Clipboard" "$content"
'
