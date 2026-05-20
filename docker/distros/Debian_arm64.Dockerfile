FROM docker.1panel.live/arm64v8/debian:12 AS build
WORKDIR /ruyi-pytest
# 使用镜像
RUN rm -rf /etc/apt/sources.list.d && mkdir /etc/apt/sources.list.d && printf "Types: deb\nURIs: http://mirrors.ustc.edu.cn/debian\nSuites: bookworm\nComponents: main contrib\nSigned-By: /usr/share/keyrings/debian-archive-keyring.gpg" > /etc/apt/sources.list.d/apt.sources

RUN apt-get update && apt-get install -y git python3 python3-pexpect python3-pytest coreutils util-linux bash sudo wget build-essential zstd locales && apt-get clean

FROM build
ARG UNAME=testuser
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME && usermod -aG sudo $UNAME

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
WORKDIR /ruyi-pytest
COPY . .
RUN ./docker/ruyi-bin-install.bash
RUN chown -R $UNAME:$UNAME /ruyi-pytest
USER $UNAME


ENTRYPOINT ["bash", "rit.bash"]