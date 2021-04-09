FROM alpine:3.13.0
LABEL maintainer="wojciech.gabryjelski@p.lodz.pl"

ENV BASEDIR /srv
ENV CONFDIR $BASEDIR/etc
ENV IPXEVER v1.21.1

# Konfiguracja DNS
ADD ipxe/embed.ipxe /tmp/embed.ipxe
ADD ipxe/embed_debug.ipxe /tmp/embed_debug.ipxe
RUN apk --update --no-cache add --virtual .build-deps build-base perl git \
  && git clone --branch $IPXEVER http://git.ipxe.org/ipxe.git \
  && cd ipxe/src \
  && sed -Ei 's/\/\/\#define PCI_CMD/\#define PCI_CMD/g' config/general.h \
  && sed -Ei 's/\/\/\#define VLAN_CMD/\#define VLAN_CMD/g' config/general.h \
  && sed -Ei 's/\/\/\#define PING_CMD/\#define PING_CMD/g' config/general.h \
  && sed -Ei 's/\/\/\IPSTAT_CMD/\IPSTAT_CMD/g' config/general.h \
  && echo "make -j$(nproc) bin-x86_64-efi/ipxe.efi EMBED=/tmp/embed.ipxe" \
  && make -j$(nproc) bin-x86_64-efi/ipxe.efi EMBED=/tmp/embed.ipxe \
  && cp -a /ipxe/src/bin-x86_64-efi/ipxe.efi $BASEDIR/ \
  && make clean \
  && echo "make -j$(nproc) bin-x86_64-efi/ipxe.efi EMBED=/tmp/embed_debug.ipxe" \
  && make -j$(nproc) bin-x86_64-efi/ipxe.efi EMBED=/tmp/embed_debug.ipxe \
  && cp -a /ipxe/src/bin-x86_64-efi/ipxe.efi $BASEDIR/ipxe_debug.efi \
  && make clean \
  && echo "make -j$(nproc) bin-x86_64-efi/snponly.efi EMBED=/tmp/embed.ipxe" \
  && make -j$(nproc) bin-x86_64-efi/snponly.efi EMBED=/tmp/embed.ipxe \
  && cp -a /ipxe/src/bin-x86_64-efi/snponly.efi $BASEDIR/snponly.efi \
  && make clean \
  && echo "make -j$(nproc) bin-x86_64-efi/snponly.efi EMBED=/tmp/embed_debug.ipxe" \
  && make -j$(nproc) bin-x86_64-efi/snponly.efi EMBED=/tmp/embed_debug.ipxe \
  && cp -a /ipxe/src/bin-x86_64-efi/snponly.efi $BASEDIR/snponly_debug.efi \
  && rm /tmp/embed.ipxe \
  && rm /tmp/embed_debug.ipxe \
  && cd / \
  && rm -rf /ipxe \
  && apk del .build-deps

ADD resolv.conf /etc/resolv.conf


# Instalacja utils i dnsmasq 
ADD dnsmasq/dnsmasq.conf $CONFDIR/dnsmasq/dnsmasq.conf
ADD dnsmasq/dnsmasq_root.conf /etc/dnsmasq.conf
RUN apk --no-cache add \
# bash \
 tcpdump \
# iproute2-ss \
# bind-tools \
 dnsmasq \
  && rm -rf /var/lib/misc/dnsmasq.leases \
  && ln -sf $CONFDIR/dnsmasq/dnsmasq.leases /var/lib/misc/

ADD nginx $CONFDIR/nginx
RUN apk add --no-cache nginx \
  && rm -rf /etc/nginx \
  && ln -sf $CONFDIR/nginx /etc/

# Instalacja monit
RUN apk add --no-cache monit \
  && rm -rf /etc/monit.d/*
ADD monit/monitrc /etc/monitrc
ADD monit/*.conf /etc/monit.d/
ADD monit/*.sh /etc/monit.d/
RUN chmod 700 /etc/monitrc
RUN chmod 700 /etc/monit.d/*.sh

# Dodanie skryptu startowego
ENV TEMPLATEDIR /srv/templates
ADD start.sh /start.sh

ENTRYPOINT ["/start.sh"]
#CMD ["/bin/sh","-c","/usr/sbin/dnsmasq -C /etc/dnsmasq.conf -d"]
