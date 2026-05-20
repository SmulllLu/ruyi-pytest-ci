FROM cyl18/revyosindocker AS build
ARG ARCH
WORKDIR /ruyi-pytest

RUN apt-get update 

RUN apt-get install -y coreutils util-linux yq grep procps bash sudo git llvm wget build-essential zstd locales && apt-get clean

FROM build
ARG UNAME=testuser
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME && usermod -aG sudo $UNAME

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
WORKDIR /ruyi-pytest
COPY . .
RUN RUYI_VERSION="$RUYI_VERSION" ./docker/ruyi-bin-install.bash
RUN chown -R $UNAME:$UNAME /ruyi-pytest
USER $UNAME


ENTRYPOINT ["bash", "rit.bash"]