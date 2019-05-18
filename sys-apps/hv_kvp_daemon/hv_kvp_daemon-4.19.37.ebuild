# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit linux-info

DESCRIPTION="Key-value pair daemon for Hyper-V virtualized guests"
HOMEPAGE="http://kernel.org"
SRC_URI=""
SLOT="4.19.37"
KEYWORDS="amd64 x86"

CONFIG_CHECK="~HYPERV_UTILS"
ERROR_HYPERV_UTILS="CONFIG_HYPERV_UTILS is not enabled. KVP daemon will not interact with the kernel."

pkg_setup() {
  if ! kernel_is 4 19 37 ; then
    eerror "This version of KVP is designed to build against the 4.19.37 version of the kernel sources."
    eerror "Please install the proper KVP version for your kernel."
    die
  fi
}

src_unpack() {
  # C files
  mkdir -p "${S}"/src
  cp "${KERNEL_DIR}"/tools/hv/*kvp*.c "${S}/src"

  # scripts
  mkdir -p "${S}"/scripts
  cp "${KERNEL_DIR}"/tools/hv/*.sh "${S}/scripts"

  # headers
  mkdir -p "${S}"/include/linux
  cp "${KERNEL_DIR}"/include/linux/hyperv.h "${S}"/include/linux
  cp "${KERNEL_DIR}"/include/uapi/linux/connector.h "${S}"/include/linux
  cp "${KERNEL_DIR}"/include/uapi/linux/hyperv.h "${S}"/include/linux
}

src_prepare() {
  # change directories
  sed -r -i 's/\/var\/opt/\/var\/lib/g' \
      "${S}"/src/*.c

  # change scripts
  sed -r -i 's/(hv_(get_(dns|dhcp)_info|set_ifconfig))/\/etc\/hyperv\/\1.sh/g' \
      "${S}"/src/*.c
}

src_compile() {
  gcc \
    -I"${S}"/include \
    "${S}"/src/*.c \
    -o "${S}"/src/${PN}
}

src_install() {
  dosbin src/${PN}

  exeinto /etc/hyperv
  doexe "${S}"/scripts/*

  newinitd "${FILESDIR}"/${PN}-initd ${PN}
}