FROM opencloudos/opencloudos9-minimal:latest AS builder
WORKDIR /ruyi-pytest

RUN dnf install -y git python3 python3-pexpect python3-pytest coreutils util-linux bash sudo wget make zstd glibc-locale-source xz bzip2 lz4
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
