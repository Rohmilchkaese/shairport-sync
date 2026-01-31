[![Build and Publish](https://github.com/Rohmilchkaese/shairport-sync/actions/workflows/docker.yml/badge.svg)](https://hub.docker.com/r/rohmilkaese/shairport-sync)

# Shairport Sync Docker Image

A lightweight Docker image for [Shairport Sync](https://github.com/mikebrady/shairport-sync), an AirPlay audio receiver for Linux. Streams audio from iOS devices, iTunes, macOS, and other AirPlay sources. Multiple instances stay in sync for multi-room audio when used with a compatible player such as iTunes or [OwnTone](https://github.com/owntone/owntone-server).

Built on Alpine Linux for a minimal footprint. Targets `linux/arm/v7` (Raspberry Pi and similar ARM devices). Includes [Apple Lossless (ALAC)](https://github.com/mikebrady/alac) support.

[Available on Docker Hub.](https://hub.docker.com/r/rohmilkaese/shairport-sync)

Fork of the original project by [Kevin Eye](https://github.com/kevineye/docker-shairport-sync).

## Versions

| Component | Version |
|---|---|
| Alpine Linux | 3.21 |
| Shairport Sync | 4.3.7 |
| Apple ALAC | 0.0.7 |

## Quick Start

### Docker Run

```bash
docker run -d \
    --name shairport-sync \
    --net host \
    --device /dev/snd \
    -v $PWD/shairport.conf:/conf/shairport.conf \
    rohmilkaese/shairport-sync:latest \
    -vu -c /conf/shairport.conf
```

### Docker Compose

```yaml
services:
  shairport-sync:
    container_name: shairport-sync
    image: rohmilkaese/shairport-sync:latest
    network_mode: host
    devices:
      - /dev/snd
    volumes:
      - ./shairport.conf:/conf/shairport.conf
    command: -vu -c /conf/shairport.conf
```

## Configuration

Place a `shairport.conf` file in the mount path. A minimal example:

```
general = {
  name = "Kitchen";
};

alsa = {
  output_device = "hw:0";
  mixer_control_name = "PCM";
};

diagnostics = {
  log_verbosity = 0;
};
```

See [`shairport.conf.full`](shairport.conf.full) for all available options, or refer to the [upstream documentation](https://github.com/mikebrady/shairport-sync/blob/master/README.md).

The `AIRPLAY_NAME` environment variable defaults to `Docker` and can be overridden with `-e AIRPLAY_NAME=MySpeaker`. This is the name that appears in AirPlay device lists when no config file is used.

## Build Features

The image is compiled with the following options:

- **ALSA** -- Linux audio output
- **Pipe** -- named pipe output
- **Avahi** -- mDNS/Bonjour service discovery
- **OpenSSL** -- TLS support
- **SoX** -- high-quality audio resampling
- **Metadata** -- track metadata support
- **Apple ALAC** -- lossless audio codec
