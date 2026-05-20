#!/bin/bash

RUYI_VERSION=${RUYI_VERSION:-"0.20.0"}

case "$(uname -m)" in
	x86_64)
		RUYI_ARCH="amd64"
		;;
	aarch64)
		RUYI_ARCH="arm64"
		;;
	riscv64)
		RUYI_ARCH="riscv64"
		;;
esac

if [[ "$RUYI_VERSION" =~ "-" ]]; then
	RUYI_LINK="https://mirror.iscas.ac.cn/ruyisdk/ruyi/testing/${RUYI_VERSION}/ruyi.${RUYI_ARCH}"
else
	RUYI_LINK="https://mirror.iscas.ac.cn/ruyisdk/ruyi/releases/${RUYI_VERSION}/ruyi.${RUYI_ARCH}"
fi

if wget --help > /dev/null; then
	wget $RUYI_LINK -O /usr/bin/ruyi
elif curl --help > /dev/null; then
	curl -L $RUYI_LINK -o /usr/bin/ruyi
else
	LOG_ERROR "missing wget/curl support"
	exit -1
fi

chmod +x /usr/bin/ruyi

