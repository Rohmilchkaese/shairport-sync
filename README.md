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
