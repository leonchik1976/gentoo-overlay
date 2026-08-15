# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="Web and API based SMTP testing tool"
HOMEPAGE="https://github.com/mailhog/MailHog"
SRC_URI="https://github.com/mailhog/MailHog/releases/download/v${PV}/MailHog_linux_amd64 -> ${P}-amd64"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

QA_PREBUILT="usr/bin/mailhog"

src_unpack() {
	cp "${DISTDIR}/${P}-amd64" mailhog || die
	chmod +x mailhog || die
}

src_test() {
	./mailhog -version || die
}

src_install() {
	dobin mailhog
}
