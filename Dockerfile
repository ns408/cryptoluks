FROM alpine:3.4

ARG user
RUN adduser -g "" -D $user

# install packages
RUN apk add --no-cache --update \
  abuild bc binutils build-base cmake gcc ncurses-dev sed \
  ca-certificates wget bash cryptsetup sudo \
  dosfstools e2fsprogs

# sudoers entry for the user
RUN echo "$user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user \
  && chmod 0400 /etc/sudoers.d/$user

# download kernel sources
ARG kernel_ver
RUN wget -nv -P /src https://www.kernel.org/pub/linux/kernel/v4.x/linux-$kernel_ver.tar.gz \
  && tar -C /src -zxf /src/linux-$kernel_ver.tar.gz \
  && rm -f /src/linux-$kernel_ver.tar.gz

# build dm-crypt module
RUN cd /src/linux-$kernel_ver \
  && make defconfig \
  && ([ ! -f /proc/1/root/proc/config.gz ] || zcat /proc/1/root/proc/config.gz > .config) \
  # enable module
  && sed -i'.bak' 's|CONFIG_DM_CRYPT=y|CONFIG_DM_CRYPT=m|' .config \
  && make oldconfig \
  && make modules_prepare \
  # build modules in this subdir only
  && make modules SUBDIRS=drivers/md \
  && mkdir -p /lib/modules/${kernel_ver}-linuxkit/kernel/drivers/md \
  && echo 'kernel/drivers/md/dm-crypt.ko: /lib/modules/${kernel_ver}-linuxkit/kernel/drivers/md/dm-crypt.ko' \
   >> /lib/modules/${kernel_ver}-linuxkit/modules.dep \
  && cp /src/linux-${kernel_ver}/drivers/md/dm-crypt.ko /lib/modules/${kernel_ver}-linuxkit/kernel/drivers/md/dm-crypt.ko \
  # cause this doesn't work: modprobe dm-crypt
  && echo 'dm-crypt' >> /etc/modules

WORKDIR /home/$user/app
