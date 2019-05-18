# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit user systemd

SRC_URI="https://github.com/Radarr/Radarr/releases/download/v${PV}/Radarr.develop.${PV}.linux.tar.gz"

DESCRIPTION="A Sonarr fork for movies."
HOMEPAGE="https://www.radarr.video"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RDEPEND="
	>=dev-lang/mono-4.4.1.0
	media-video/mediainfo 
	dev-db/sqlite"
IUSE="+updater"
MY_PN=Radarr
S=${WORKDIR}/${MY_PN}

pkg_setup() {
	enewgroup ${PN}
	enewuser ${PN} -1 -1 /var/radarr ${PN}
}

src_install() {
	newconfd "${FILESDIR}/${PN}.conf" ${PN}
	newinitd "${FILESDIR}/${PN}.init" ${PN}

	keepdir /var/${PN}
	fowners -R ${PN}:${PN} /var/${PN}

	insinto /etc/${PN}
	insopts -m0660 -o ${PN} -g ${PN}

	insinto /etc/logrotate.d
	insopts -m0644 -o root -g root
	newins "${FILESDIR}/${PN}.logrotate" ${PN}

	dodir  "/usr/share/${PN}"
	cp -R "${WORKDIR}/${MY_PN}/." "${D}/usr/share/radarr" || die "Install failed!"

	# Allow auto-updater, make source owned by radarr user.
	if use updater; then
		fowners -R ${PN}:${PN} /usr/share/${PN}
	fi

	systemd_dounit "${FILESDIR}/radarr.service"
	systemd_newunit "${FILESDIR}/radarr.service" "${PN}@.service"
}