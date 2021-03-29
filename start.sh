#!/bin/sh

# Ustawienie strefy czasowej
if ! [[ -z "$TIME_ZONE" ]]; then
  ln -sf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime
fi

MONIT_OPT=-I
if ! [[ -z "$DEBUG" ]]; then
  MONIT_OPT="$MONIT_OPT -vvv"
fi
monit $MONIT_OPT
