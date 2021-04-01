#!/bin/sh

# Ustawienie strefy czasowej
if ! [[ -z "$TIME_ZONE" ]]; then
  ln -sf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime
fi

MONIT_OPT=-I
if ! [[ -z "$DEBUG" ]]; then
  MONIT_OPT="$MONIT_OPT -vvv"
fi

# kiedy monit startuje i znajduje wlasny pid /run/monit.pid,
# to sprawdza czy proces o tym pid juz dziala
# jezeli inny proces uruchomi sie na tym pid
# to monit sie nie uruchamia
if [[ -f /run/monit.pid ]]; then
  rm /run/monit.pid
fi

monit $MONIT_OPT
