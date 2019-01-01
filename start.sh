#!/bin/sh

trap trapSignal HUP INT QUIT TERM

killproc() {
 PROC=$1
 
 PID=$(pidof $PROC)
 kill $PID
 sleep 1
 $(pidof $PROC)
 if ! [ -z $? ]; then kill -9 $PID; fi
 $(pidof $PROC)
 if [ -z $? ]; then exit 1; else exit 0; fi
}

trapSignal() {
  echo "Stopping httd..."
  nginx stop
  echo "Stopping dnsmasq..."
  killproc dnsmasq
}

echo "Starting httpd..."
if ! [ -d ${TEMPLATEDIR} ]; then mkdir -p ${TEMPLATEDIR}; fi
# Korekta katalogu domowego serwera http
sed -i -E "s/(^.*root )(.*)(;$)/\1${TEMPLATEDIR}\3/g" /etc/nginx/conf.d/default.conf
#/bin/busybox-extras httpd -p 80 -h ${TEMPLATEDIR} -f -vvv &
nginx
echo "Starting dhcp and tftp..."
/usr/sbin/dnsmasq -C /etc/dnsmasq.conf -d &

echo "[hit enter key to exit] or run 'docker stop <container>'"
read

trapSignal
exit 0
