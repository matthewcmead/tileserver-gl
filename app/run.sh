#!/bin/bash

_term() {
	echo "Caught signal, stopping gracefully"
	kill -TERM "$child" 2>/dev/null
}

trap _term TERM


/usr/bin/Xvfb :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &
disown %1
echo "Waiting 3 seconds for xvfb to start..."
sleep 3

export DISPLAY=:99.0

cd /data
node /usr/src/app/ -p 80 "$@" &
child=$!
wait "$child"

kill -9 $(ps -ef | grep Xvfb | grep -v grep | awk '{print $2;}')
