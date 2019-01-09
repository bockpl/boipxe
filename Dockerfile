FROM alpine
LABEL maintainer="seweryn.sitarski@p.lodz.pl"

# Konfiguracja DNS
ADD resolv.conf /etc/resolv.conf

# Instalacja Dnsmasq
RUN apk add --no-cache dnsmasq
ADD dnsmasq/dnsmasq_root.conf /etc/dnsmasq.conf

# Instalacja iPXE
ADD ipxe/embed.ipxe /tmp/embed.ipxe
RUN apk add --no-cache --virtual build-dependencies build-base perl git

RUN git clone git://git.ipxe.org/ipxe.git \
  && cd ipxe/src \
  && echo "make -j$(nproc) bin-x86_64-efi/ipxe.efi EMBED=/tmp/embed.ipxe" \
  && make -j$(nproc) bin-x86_64-efi/ipxe.efi EMBED=/tmp/embed.ipxe \
  && cp -a /ipxe/src/bin-x86_64-efi/ipxe.efi /srv/ \
  && cd / \
  && rm -rf /ipxe \
  && apk del -r build-dependencies build-base perl git

# Instalacja modulu httpd do busybox
#RUN apk add busybox-extras
#RUN apk add lighttpd
RUN apk add nginx
ADD nginx/nginx.conf /etc/nginx/nginx.conf
ADD nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# Instalacja i konfiguracja sshd do polaczen i synchronizacji rsync
#RUN apk add openssh-server
#RUN ssh-keygen -A
#ADD ssh/id_rsa.pub /root/.ssh/authorized_keys

# Dodanie skryptu startowego
ENV TEMPLATEDIR /srv/templates
ADD start.sh /start.sh

ENTRYPOINT ["/start.sh"]
#CMD ["/bin/sh","-c","/usr/sbin/dnsmasq -C /etc/dnsmasq.conf -d"]
