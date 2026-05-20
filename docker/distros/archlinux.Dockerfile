FROM archlinux/archlinux:latest AS builder
WORKDIR /ruyi-pytest

# RUN echo "Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
# RUN sed -i '/^NoExtract  = usr\/share\/locale\/\* usr\/share\/X11\/locale\/\* usr\/share\/i18n\/\*/d' /etc/pacman.conf
RUN rm -v /etc/pacman.conf.d/*noextract*.conf && pacman-key --init && pacman --noconfirm -Syyu && pacman --need --noconfirm -S git python python-pexpect python-pytest glibc-locales sudo make jq tar unzip
RUN sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && sed -i 's/^#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen && locale-gen && echo 'LANG=en_US.UTF-8' > /etc/locale.conf


FROM builder
ARG UNAME=ruyisdk_test
RUN useradd -mG wheel -s /bin/bash $UNAME
RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR /ruyi-pytest
ARG RUYI_VERSION
COPY . .
RUN RUYI_VERSION="$RUYI_VERSION" ./docker/ruyi-bin-install.bash
RUN chown -R $UNAME:$UNAME /ruyi-pytest
USER $UNAME

ENTRYPOINT ["docker/test_run.sh"]
