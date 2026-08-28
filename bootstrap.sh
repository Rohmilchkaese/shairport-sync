#!/bin/sh
# Clean stale runtime files so a container restart doesn't wedge:
# a leftover dbus.pid blocks dbus ("Failed to start message bus"), and a
# leftover avahi pid both blocks avahi-daemon AND fools a pid-file readiness
# check into launching shairport-sync with no working mDNS.
rm -f /run/dbus/dbus.pid /run/dbus/pid /run/avahi-daemon/pid
mkdir -p /run/dbus
dbus-uuidgen --ensure

# Start system D-Bus and wait for its socket before anything that needs the bus.
dbus-daemon --system --fork
i=0
while [ ! -S /run/dbus/system_bus_socket ] && [ "$i" -lt 30 ]; do
	sleep 0.1; i=$((i + 1))
done

# Start Avahi and wait until it is actually responding (not just a pid file),
# so shairport-sync's mDNS init doesn't race it.
avahi-daemon --daemonize --no-chroot
i=0
while ! avahi-daemon --check 2>/dev/null && [ "$i" -lt 50 ]; do
	sleep 0.1; i=$((i + 1))
done

# NQPTP (AirPlay 2 timing) before shairport-sync.
nqptp &

exec shairport-sync -m avahi "$@"
