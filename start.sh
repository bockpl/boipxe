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
nginx
echo "Starting open-sshd..."
/usr/sbin/sshd
echo "Starting dhcp and tftp..."
##
# I also needed to add the --dhcp-broadcast flag to dnsmasq 
# within the container to get it to actually broadcast DHCPOFFER messages on the network.
# For some reason, dnsmasq was trying to unicast the DHCPOFFER messages,
# and it was using ARP to try to get an address that had not yet been assigned.
#
##
/usr/sbin/dnsmasq -C /etc/dnsmasq.conf -d --dhcp-broadcast &

echo "[hit enter key to exit] or run 'docker stop <container>'"
read

trapSignal
exit 0
