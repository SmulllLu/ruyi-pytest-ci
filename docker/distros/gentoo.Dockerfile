FROM gentoo/portage:latest AS portage
FROM gentoo/stage3:latest AS builder

COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

WORKDIR /ruyi-pytest

# RUN mkdir -p /etc/portage/repos.conf && printf "[gentoo]\nlocation = /var/db/repos/gentoo\nsync-type = rsync\nsync-uri = rsync://mirrors.tuna.tsinghua.edu.cn/gentoo-portage\nauto-sync = yes" > /etc/portage/repos.conf/gentoo.conf && 
RUN echo MAKEOPTS="-j8" >> /etc/portage/make.conf && echo "USE=-doc" >> /etc/portage/make.conf # && sed -i 's/-O2/-O0/' /etc/portage/make.conf
RUN emerge --sync --color=n
RUN eselect profile list
RUN mkdir -p /etc/portage/binrepos.conf && printf '%s\n' '[gentoobinhost]' 'priority = 9999' 'sync-uri = https://distfiles.gentoo.org/releases/amd64/binpackages/23.0/x86-64/' 'auto-sync = yes' >> /etc/portage/binrepos.conf/gentoobinhost.conf
RUN echo 'FEATURES="${FEATURES} getbinpkg"'  >> /etc/portage/make.conf && echo 'FEATURES="${FEATURES} binpkg-request-signature"' >> /etc/portage/make.conf && getuto
# j6 8G 内存会被 oom kill
RUN emerge --color=n --getbinpkg --noreplace --autounmask=y dev-python/pexpect dev-python/pytest coreutils util-linux grep procps bash sudo wget make app-arch/zstd openssl
RUN emerge --color=n --getbinpkg --noreplace --autounmask=y dev-vcs/git dev-build/make app-arch/tar

FROM builder
ARG UNAME=ruyisdk_test
RUN useradd -m -s /bin/bash $UNAME

RUN echo 'ruyisdk_test ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
WORKDIR /ruyi-pytest
COPY . .
RUN chown -R $UNAME:$UNAME /ruyi-pytest
USER $UNAME


ENTRYPOINT ["docker/test_run.sh"]
