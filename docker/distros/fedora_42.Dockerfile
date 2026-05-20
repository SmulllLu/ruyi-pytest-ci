FROM fedora:42 AS builder
WORKDIR /ruyi-pytest

# RUN sed -e 's|^metalink=|#metalink=|g' -e 's|^#baseurl=http://download.example/pub/fedora/linux|baseurl=https://mirrors.ustc.edu.cn/fedora|g' -i.bak /etc/yum.repos.d/fedora.repo /etc/yum.repos.d/fedora-updates.repo


RUN dnf install -y git python3 python3-pexpect python3-pytest coreutils util-linux grep bash sudo wget make zstd lz4 unzip jq glibc-locale-source
RUN echo 'LANG=en_US.UTF-8' > /etc/locale.conf
RUN localedef -i en_US -f UTF-8 en_US.UTF-8 && localedef -i zh_CN -f UTF-8 zh_CN.UTF-8

FROM builder
ARG UNAME=ruyisdk_test
RUN useradd -mG wheel -s /bin/bash $UNAME
RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR /ruyi-pytest
COPY . .
ARG RUYI_VERSION
RUN RUYI_VERSION="$RUYI_VERSION" ./docker/ruyi-bin-install.bash
RUN chown -R $UNAME:$UNAME /ruyi-pytest
USER $UNAME


ENTRYPOINT ["docker/test_run.sh"]
