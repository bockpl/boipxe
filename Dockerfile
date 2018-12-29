FROM alpine
LABEL maintainer="seweryn.sitarski@p.lodz.pl"

# Konfiguracja DNS
ADD resolv.conf /etc/resolv.cof

# Instalacja Dnsmasq
RUN apk add --no-cache dnsmasq
ADD dnsmasq/dnsmasq.conf /etc/dnsmasq.conf

# Instalacja iPXE
ADD ipxe/embed.ipxe /tmp/embed.ipxe
RUN (apk add --no-cache --virtual build-dependencies build-base perl git) \
  && (git clone git://git.ipxe.org/ipxe.git) \
  && (cd ipxe/src; make bin-x86_64-efi/ipxe.efi EMBED=/tmp/embed.ipxe) \
  && (mv bin-x86_64-efi/ipxe.efi /srv/) \
  && (cd /; rm -rf /ipxe) \
  && (apk del --virtual build-dependencies build-base perl git)

CMD "dnsmasq -C /etc/dnsmasq.conf -d"
