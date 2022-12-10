#!/bin/sh

rm -rf /var/run
rm -rf /run/dbus/dbus.pid
mkdir -p /var/run/dbus
dbus-uuidgen --ensure
sleep 1
dbus-daemon --system
nqptp &

avahi-daemon --daemonize --no-chroot

shairport-sync -m avahi "$@"