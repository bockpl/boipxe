#!/bin/sh
/usr/sbin/dnsmasq -C /etc/dnsmasq.conf --dhcp-broadcast --log-facility=/dev/console
