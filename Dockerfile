FROM alpine
LABEL maintainer="seweryn.sitarski@p.lodz.pl"

ENV BASEDIR /srv
ENV CONFDIR $BASEDIR/etc

# Konfiguracja DNS
ADD resolv.conf /etc/resolv.conf

# Instalacja Dnsmasq
RUN apk add --no-cache dnsmasq
ADD dnsmasq/dnsmasq_root.conf /etc/dnsmasq.conf
ADD dnsmasq/dnsmasq.conf $CONFDIR/dnsmasq/dnsmasq.conf

# Instalacja iPXE
ADD ipxe/embed.ipxe /tmp/embed.ipxe
RUN apk add --no-cache --virtual build-dependencies build-base perl git

RUN git clone git://git.ipxe.org/ipxe.git \
  && cd ipxe/src \
  && echo "make -j$(nproc) bin-x86_64-efi/ipxe.efi EMBED=/tmp/embed.ipxe" \
  && make -j$(nproc) bin-x86_64-efi/ipxe.efi EMBED=/tmp/embed.ipxe \
  && cp -a /ipxe/src/bin-x86_64-efi/ipxe.efi $BASEDIR/ \
  && rm /tmp/embed.ipxe \
  && cd / \
  && rm -rf /ipxe \
  && apk del -r build-dependencies build-base perl git

# Instalacja modulu httpd do busybox
#RUN apk add busybox-extras
#RUN apk add lighttpd
RUN apk add nginx
ADD nginx $CONFDIR/nginx
RUN rm -rf /etc/nginx && ln -sf $CONFDIR/nginx /etc/

# Instalacja i konfiguracja sshd
ADD ssh/sshd_config $CONFDIR/ssh/sshd_config
ADD ssh/authorized_keys $CONFDIR/ssh/authorized_keys
RUN ln -sf $CONFDIR/ssh /etc/ssh
RUN apk add openssh-server \
  && ssh-keygen -A \
  && apk add openssh-client \
  && mkdir /root/.ssh && ln -sf $CONFDIR/ssh/authorized_keys /root/.ssh/authorized_keys

# Dodanie skryptu startowego
ENV TEMPLATEDIR /srv/templates
ADD start.sh /start.sh

ENTRYPOINT ["/start.sh"]
#CMD ["/bin/sh","-c","/usr/sbin/dnsmasq -C /etc/dnsmasq.conf -d"]
