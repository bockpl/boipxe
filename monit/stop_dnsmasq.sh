#!/bin/sh

echo "stopping dnsmasq"
PID=$(pidof  dnsmasq)
kill $PID
sleep 1

PID=$(pidof $PROC)
if ! [ -n $PID ]; then
  kill -9 $PID;
fi

$(pidof $PROC)
if [ -n $? ]; then exit 1; else exit 0; fi
