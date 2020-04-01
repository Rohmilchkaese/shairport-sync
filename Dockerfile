FROM alpine:edge
MAINTAINER 37877524+Rohmilchkaese@users.noreply.github.com

RUN env \
&& apk -U add \
	git \
	build-base \
	autoconf \
	automake \
	libtool \
	alsa-lib-dev \
	libdaemon-dev \
	popt-dev \
	libressl-dev \
	soxr-dev \
	avahi-dev \
	xmltoman \
	libconfig-dev \
	libstdc++ \
&& cd /root \
&& git clone "https://github.com/mikebrady/alac.git" \
&& cd /root/alac \
&& ([ -n "$ALAC_BRANCH" ] && git checkout "$ALAC_BRANCH" ;:) \
&& autoreconf -fi \
&& ./configure \
&& make \
&& make install \
&& cd /root \
&& git clone "https://github.com/mikebrady/shairport-sync.git" \
&& cd /root/shairport-sync \
&& ([ -n "$SHAIRPORT_BRANCH" ] && git checkout "$SHAIRPORT_BRANCH" ;:) \
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
&& make install \
&& ldconfig / \
&& cd / \
&& apk --purge del \
	git \
        build-base \
        autoconf \
        automake \
        libtool \
        alsa-lib-dev \
        libdaemon-dev \
        popt-dev \
        libressl-dev \
        soxr-dev \
        avahi-dev \
        libconfig-dev \
        xmltoman \
        libconfig-dev \
        libstdc++ \
&& apk add \
        dbus \
        alsa-lib \
        libdaemon \
        popt \
        libressl \
        soxr \
        avahi \
        libconfig \
        libstdc++ \
&& rm -rf \
        /etc/ssl \
        /var/cache/apk/* \
        /lib/apk/db/* \
        /root/shairport-sync \
	/root/alac
COPY bootstrap.sh /start
RUN chmod +x /start
ENV AIRPLAY_NAME Docker
ENTRYPOINT [ "/start" ]
