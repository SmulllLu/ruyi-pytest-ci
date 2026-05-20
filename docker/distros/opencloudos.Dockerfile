FROM opencloudos/opencloudos9-minimal:latest AS builder
WORKDIR /ruyi-pytest

RUN dnf install -y git python3 python3-pexpect python3-pytest coreutils util-linux bash sudo wget make zstd jq glibc-locale-source xz bzip2 lz4 unzip
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
