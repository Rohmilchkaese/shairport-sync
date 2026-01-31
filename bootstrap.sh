#!/bin/sh
mkdir -p /var/run/dbus
dbus-uuidgen --ensure
rm -f /run/dbus/dbus.pid
dbus-daemon --system
avahi-daemon --daemonize --no-chroot

# Wait for avahi-daemon to be ready
while [ ! -f /run/avahi-daemon/pid ]; do
	sleep 0.1
done

nqptp &

exec shairport-sync -m avahi "$@"
