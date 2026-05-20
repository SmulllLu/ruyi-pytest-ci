FROM openkylin/openkylin:2.0 AS builder
ARG ARCH
WORKDIR /ruyi-pytest


RUN apt-get update && apt-get install -y git python3 python3-pexpect python3-pytest coreutils util-linux bash sudo wget build-essential zstd locales && apt-get clean
RUN sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

FROM builder
ARG UNAME=ruyisdk_test
RUN useradd -mG sudo -s /bin/bash $UNAME

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
WORKDIR /ruyi-pytest
COPY . .
ARG RUYI_VERSION
RUN RUYI_VERSION="$RUYI_VERSION" ./docker/ruyi-bin-install.bash
RUN chown -R $UNAME:$UNAME /ruyi-pytest
USER $UNAME

ENTRYPOINT ["docker/test_run.sh"]
