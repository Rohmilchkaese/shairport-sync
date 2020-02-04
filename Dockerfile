FROM alpine:3.23 AS builder
ARG ALAC_BRANCH=tags/0.0.7
ARG SHAIRPORT_BRANCH=4.3.7

RUN apk add --no-cache \
	git \
	build-base \
	autoconf \
	automake \
	libtool \
	alsa-lib-dev \
	libdaemon-dev \
	popt-dev \
	openssl-dev \
	soxr-dev \
	avahi-dev \
	xmltoman \
	libconfig-dev

RUN cd /root \
	&& git clone "https://github.com/mikebrady/alac.git" \
	&& cd /root/alac \
	&& git checkout "$ALAC_BRANCH" \
	&& autoreconf -fi \
	&& ./configure \
	&& make \
	&& make install

RUN cd /root \
	&& git clone "https://github.com/mikebrady/shairport-sync.git" \
	&& cd /root/shairport-sync \
	&& git checkout "$SHAIRPORT_BRANCH" \
	&& autoreconf -i -f \
	&& ./configure \
		--with-alsa \
		--with-pipe \
		--with-avahi \
		--with-ssl=openssl \
		--with-soxr \
		--with-metadata \
		--with-apple-alac \
	&& make \
	&& make install

FROM alpine:3.23
RUN apk add --no-cache \
	dbus \
	alsa-lib \
	libdaemon \
	popt \
	libssl3 \
	libcrypto3 \
	soxr \
	avahi \
	libconfig \
	libstdc++

COPY --from=builder /usr/local/bin/shairport-sync /usr/local/bin/shairport-sync
COPY --from=builder /usr/local/etc/shairport-sync.conf /usr/local/etc/shairport-sync.conf
COPY --from=builder /usr/local/lib/libalac.so* /usr/local/lib/
RUN ldconfig /usr/local/lib

COPY bootstrap.sh /start
RUN chmod +x /start
ENV AIRPLAY_NAME=Docker
ENTRYPOINT [ "/start" ]
