# shairport-sync
shairport-sync docker image - including Apple Alac decoder - based on Alpine Linux 

[shairport-sync](https://github.com/mikebrady/shairport-sync) is an Apple AirPlay receiver. It can receive audio directly from iOS devices, iTunes, etc. Multiple instances of shairport-sync will stay in sync with each other and other AirPlay devices when used with a compatible multi-room player, such as iTunes or [forked-daapd](https://github.com/jasonmc/forked-daapd).

This is a fork of the project by [Kevin Eye](https://github.com/kevineye/docker-shairport-sync).

## Docker Run

Command:

```bash
sudo docker run -d \
-v $PWD:/conf/ \
--net host \
--device /dev/snd \
--name shairport-sync \
rohmilkaese/shairport-sync \
-vu -c /conf/shairport.conf
```
Place a valid shairport.conf file in directory you run the docker run command.

## Docker Compose

docker-compose.yaml
```bash
version: "2.2"
services:
   shairport-sync:
    container_name: shairport-sync
    image: rohmilkaese/shairport-sync:latest
    volumes:
       - /conf/shairport.conf/etc/shairport.conf
    devices:
       - /dev/snd
    command: -vu -c conf/shairport.conf
    network_mode: "host"
```
Place a valid shairport.conf file in /conf directory.
