FROM debian:trixie AS builder
WORKDIR /ruyi-pytest

# RUN rm -rf /etc/apt/sources.list.d && mkdir /etc/apt/sources.list.d && printf "Types: deb\nURIs: http://mirrors.ustc.edu.cn/debian\nSuites: bookworm\nComponents: main contrib\nSigned-By: /usr/share/keyrings/debian-archive-keyring.gpg" > /etc/apt/sources.list.d/apt.sources

RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" && apt-get install -y git python3 python3-pexpect python3-pytest coreutils util-linux sudo make tar build-essential locales tzdata wget zstd lz4 unzip && apt-get clean
RUN sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

FROM builder
ARG UNAME=ruyisdk_test
RUN useradd -mG sudo -s /bin/bash $UNAME
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
WORKDIR /ruyi-pytest
COPY . .
RUN ./docker/ruyi-bin-install.bash
RUN chown -R $UNAME:$UNAME /ruyi-pytest
USER $UNAME

ENTRYPOINT ["docker/test_run.sh"]
