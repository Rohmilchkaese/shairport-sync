#!/bin/sh
mkdir -p /var/run/dbus
dbus-uuidgen --ensure
sleep 1
rm -rf /run/dbus/dbus.pid
dbus-daemon --system
avahi-daemon --daemonize --no-chroot
shairport-sync -m avahi "$@"