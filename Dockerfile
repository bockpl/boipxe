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
ADD ipxe/embed_debug.ipxe /tmp/embed_debug.ipxe
RUN apk --update --no-cache add --virtual .build-deps build-base perl git \
  && git clone http://git.ipxe.org/ipxe.git \
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
