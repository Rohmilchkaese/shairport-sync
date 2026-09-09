[![Test](https://github.com/rohmilchkaese/shairport-sync/actions/workflows/test.yml/badge.svg)](https://github.com/rohmilchkaese/shairport-sync/actions/workflows/test.yml)
[![Publish](https://github.com/rohmilchkaese/shairport-sync/actions/workflows/publish.yml/badge.svg)](https://github.com/rohmilchkaese/shairport-sync/actions/workflows/publish.yml)

# Shairport Sync as a Docker Image

[Shairport Sync](https://github.com/mikebrady/shairport-sync) is an Apple AirPlay 2 receiver. It can receive audio directly from iOS devices, iTunes, etc. Multiple instances of Shairport Sync will stay in sync with each other and other AirPlay devices when used with a compatible multi-room player, such as iTunes or [OwnTone](https://github.com/owntone/owntone-server).

This Docker image provides an easy way to deploy Shairport Sync. Based on Alpine Linux, the image is very small and it is built for multiple platforms, making it suitable for embedded devices such as Raspberry Pi. Support for the Apple Lossless Audio Codec (ALAC) is included.

Supported architectures: `linux/amd64`, `linux/arm64`, `linux/arm/v7`

[See available images on Docker Hub.](https://hub.docker.com/r/rohmilkaese/shairport-sync)

This is a fork of the project by [Kevin Eye](https://github.com/kevineye/docker-shairport-sync).

> **Note:** AirPlay 2 requires host networking (`--net host`) so that the PTP timing protocol (NQPTP) can function correctly. The `docker run` and `docker-compose.yaml` examples below already use host networking.

## Docker Run

Command:

```bash
docker run -d \
    -v $PWD:/conf/ \
    --net host \
    --device /dev/snd \
    --name shairport-sync \
    rohmilkaese/shairport-sync \
    -vu -c /conf/shairport.conf
```
Place a valid shairport.conf file in directory you run the docker run command.

## Docker Compose

See [docker-compose.yaml](docker-compose.yaml). Place a valid shairport.conf file in the `./conf/` directory, then run:

```bash
docker compose up -d
```

## Cross-VLAN / Cross-Subnet Issues

AirPlay 2 can be unreliable across VLANs/subnets **by default**: iOS often prefers IPv6 link-local addresses (`fe80::`) that can't be routed across subnets, and mDNS discovery doesn't cross subnet boundaries on its own. This is an Apple AirPlay / network-topology issue, not a shairport-sync bug — and **whether it works is dependent on your network setup** (see the two options below).

See: [GitHub Issue #1753](https://github.com/mikebrady/shairport-sync/issues/1753)

**Symptoms:**
- Device appears in AirPlay menu
- "Unable to connect" or connection times out
- Works when iPhone and shairport-sync are on the same VLAN

**Solutions (setup-dependent):**

- **Simplest — same VLAN as your iOS devices** (via Docker macvlan, below). Guaranteed, no network gymnastics.
- **Cross-VLAN — keep shairport-sync on its own VLAN, but bridge discovery.** AirPlay 2 *does* work across subnets **if your network carries discovery/multicast between VLANs** — e.g. an **IGMP querier** for multicast plus an **mDNS reflector/repeater** (Avahi reflector, or your router/switch's mDNS repeater) so devices can find each other; the AirPlay-2 unicast traffic then routes normally. This is how a router-per-VLAN setup runs shairport-sync on a dedicated "Container"/IoT VLAN while phones sit on the main VLAN. Reliability depends on your gear handling cross-VLAN multicast/mDNS correctly.

### Using Docker Macvlan (Multi-VLAN Setup)

If your Docker host is on a different VLAN than your iOS devices, you can use a macvlan network to place the shairport-sync container on the correct VLAN.

**Example:** Docker host on Container VLAN (172.16.40.0/24), iOS devices on LAN VLAN (192.168.100.0/24).

1. **Create VLAN interface on Docker host** (if not using native VLAN):
   ```bash
   # On the Pi/Docker host, create VLAN interface for LAN (VLAN ID 1)
   sudo ip link add link eth0 name eth0.1 type vlan id 1
   sudo ip link set eth0.1 up
   ```

2. **Create macvlan network:**
   ```bash
   docker network create -d macvlan \
     --subnet=192.168.100.0/24 \
     --gateway=192.168.100.1 \
     -o parent=eth0.1 \
     lan_macvlan
   ```

3. **Update docker-compose.yaml:**
   ```yaml
   services:
     shairport-sync:
       container_name: shairport-sync
       image: rohmilkaese/shairport-sync:latest
       volumes:
         - ./conf/shairport.conf:/conf/shairport.conf
       devices:
         - /dev/snd
       command: -vu -c /conf/shairport.conf
       networks:
         lan_macvlan:
           ipv4_address: 192.168.100.50
       cap_add:
         - NET_ADMIN
         - NET_RAW

   networks:
     lan_macvlan:
       external: true
   ```

4. **Update shairport.conf** to bind to the macvlan interface:
   ```
   general = {
       name = "Wohnzimmer";
       // ... other settings
   };
   ```

**Note:** With macvlan, the container cannot communicate with the Docker host directly. If you need host-to-container communication, create a macvlan interface on the host as well.
