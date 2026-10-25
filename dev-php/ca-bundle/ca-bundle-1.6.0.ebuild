# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit prefix

DESCRIPTION="Find the system CA bundle or fall back to the Mozilla one"
HOMEPAGE="https://github.com/composer/ca-bundle"
SRC_URI="https://github.com/composer/ca-bundle/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-lang/php-7.2:*[ssl]
	dev-php/fedora-autoloader"

src_prepare() {
	default
	# Keep the fallback bundle private to this library.
	sed -i "s@/../res/cacert.pem@/res/cacert.pem@" src/CaBundle.php || die
}

src_install() {
	insinto /usr/share/php/Composer/CaBundle
	doins src/CaBundle.php \
		"$(prefixify_ro "${FILESDIR}"/autoload.php)"
	doins -r res
	dodoc README.md
}
