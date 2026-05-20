FROM fedora:43 AS builder
WORKDIR /ruyi-pytest

# RUN sed -e 's|^metalink=|#metalink=|g' -e 's|^#baseurl=http://download.example/pub/fedora/linux|baseurl=https://mirrors.ustc.edu.cn/fedora|g' -i.bak /etc/yum.repos.d/fedora.repo /etc/yum.repos.d/fedora-updates.repo


RUN dnf install -y git python3 python3-pexpect python3-pytest coreutils util-linux bash sudo wget make zstd glibc-locale-source
RUN echo 'LANG=en_US.UTF-8' > /etc/locale.conf

FROM builder
ARG UNAME=ruyisdk_test
RUN useradd -mG wheel -s /bin/bash $UNAME
RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR /ruyi-pytest
COPY . .
RUN ./docker/ruyi-bin-install.bash
RUN chown -R $UNAME:$UNAME /ruyi-pytest
USER $UNAME


ENTRYPOINT ["docker/test_run.sh"]
