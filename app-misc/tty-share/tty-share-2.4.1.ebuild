# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit go-module

DESCRIPTION="Share a terminal through a browser or another terminal"
HOMEPAGE="https://tty-share.com https://github.com/elisescu/tty-share"
SRC_URI="https://github.com/elisescu/tty-share/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

# Includes the vendored Go dependencies and bundled browser assets.
LICENSE="Apache-2.0 BSD MIT MPL-2.0"
SLOT="0"
KEYWORDS="~arm64"

src_compile() {
	ego build -mod=vendor -trimpath -o tty-share .
}

src_install() {
	dobin tty-share
	dodoc README.md
}
