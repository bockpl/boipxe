FROM alpine
LABEL maintainer="seweryn.sitarski@p.lodz.pl"

# Konfiguracja DNS
ADD resolv.conf /etc/resolv.conf

# Instalacja Dnsmasq
RUN apk add --no-cache dnsmasq
ADD dnsmasq/dnsmasq.conf /etc/dnsmasq.conf

# Instalacja iPXE
ADD ipxe/embed.ipxe /tmp/embed.ipxe
RUN (apk add --no-cache --virtual build-dependencies build-base perl git) \
  && (git clone git://git.ipxe.org/ipxe.git) \
  && (cd ipxe/src; make -j2 bin-x86_64-efi/ipxe.efi EMBED=/tmp/embed.ipxe) \
  && (cp -a /ipxe/src/bin-x86_64-efi/ipxe.efi /srv/) \
  && (cd /; rm -rf /ipxe) \
  && (apk del --virtual build-dependencies build-base perl git)

CMD "/usr/sbin/dnsmasq -C /etc/dnsmasq.conf -d"
