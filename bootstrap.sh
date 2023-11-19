#!/bin/sh
mkdir -p /var/run/dbus
dbus-uuidgen --ensure
sleep 1
dbus-daemon --system
avahi-daemon --daemonize --no-chroot
shairport-sync -m avahi "$@"