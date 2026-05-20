FROM openeuler/openeuler:25.03 AS builder
WORKDIR /ruyi-pytest

# RUN rm -rf /etc/yum.repos.d/* 
# RUN if [ "$ARCH" = "amd64" ]; then echo -e "[openeuler]\nname=openeuler\nbaseurl=https://mirrors.ustc.edu.cn/openeuler/openEuler-24.03-LTS/OS/x86_64\nenabled=1\ngpgcheck=0" > /etc/yum.repos.d/openeuler.repo ; else echo -e "[openeuler]\nname=openeuler\nbaseurl=https://mirrors.ustc.edu.cn/openeuler/openEuler-24.03-LTS/OS/aarch64\nenabled=1\ngpgcheck=0" > /etc/yum.repos.d/openeuler.repo ; fi

RUN dnf upgrade -y && dnf install -y git python3 python3-pexpect python3-pytest coreutils util-linux grep procps bash sudo wget make zstd xz unzip jq
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
