FROM alpine
LABEL maintainer="seweryn.sitarski@p.lodz.pl"

ENV BASEDIR /srv
ENV CONFDIR $BASEDIR/etc

# Konfiguracja DNS
ADD resolv.conf /etc/resolv.conf

# Instalacja Dnsmasq
RUN apk --no-cache add dnsmasq
ADD dnsmasq/dnsmasq_root.conf /etc/dnsmasq.conf
ADD dnsmasq/dnsmasq.conf $CONFDIR/dnsmasq/dnsmasq.conf

# Instalacja iPXE
ADD ipxe/embed.ipxe /tmp/embed.ipxe
RUN apk --update --no-cache add --virtual .build-deps build-base perl git \
  && git clone http://git.ipxe.org/ipxe.git \
  && cd ipxe/src \
  && echo "make -j$(nproc) bin-x86_64-efi/ipxe.efi EMBED=/tmp/embed.ipxe" \
  && make -j$(nproc) bin-x86_64-efi/ipxe.efi EMBED=/tmp/embed.ipxe \
  && cp -a /ipxe/src/bin-x86_64-efi/ipxe.efi $BASEDIR/ \
  && rm /tmp/embed.ipxe \
  && cd / \
  && rm -rf /ipxe \
  && apk del .build-deps

# Instalacja modulu httpd do busybox
#RUN apk --no-cache add busybox-extras
#RUN apk --no-cache add lighttpd

ADD nginx $CONFDIR/nginx
RUN apk add --no-cache nginx \
  && rm -rf /etc/nginx \
  && ln -sf $CONFDIR/nginx /etc/

# Instalacja i konfiguracja sshd
ADD ssh/sshd_config $CONFDIR/ssh/sshd_config
ADD ssh/authorized_keys $CONFDIR/ssh/authorized_keys
RUN ln -sf $CONFDIR/ssh /etc/ssh \
  && apk add --no-cache openssh-server \
  && ssh-keygen -A \
  && apk add --no-cache openssh-client \
  && mkdir /root/.ssh \
  && ln -sf $CONFDIR/ssh/authorized_keys /root/.ssh/authorized_keys \
  && chmod 600 $CONFDIR/ssh/authorized_keys \
  && chmod 700 /root/.ssh \
  && sed -i s/root:!:/root::/g /etc/shadow

# Dodanie skryptu startowego
ENV TEMPLATEDIR /srv/templates
ADD start.sh /start.sh

ENTRYPOINT ["/start.sh"]
#CMD ["/bin/sh","-c","/usr/sbin/dnsmasq -C /etc/dnsmasq.conf -d"]
