# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

MY_PN="semver"

DESCRIPTION="Semantic version parser and range evaluator for Node.js"
HOMEPAGE="https://github.com/npm/node-semver"
SRC_URI="https://registry.npmjs.org/${MY_PN}/-/${MY_PN}-${PV}.tgz -> ${P}.tgz"
S="${WORKDIR}/package"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="net-libs/nodejs"
BDEPEND="net-libs/nodejs"

src_compile() {
	:
}

src_test() {
	node -e '
		const semver = require("./");
		if (!semver.gte("2.1131.0", "2.14.0")) process.exit(1);
		if (semver.gte("2.13.0", "2.14.0")) process.exit(1);
	' || die "semver API smoke test failed"

	[[ $(node bin/semver.js 1.2.3) == "1.2.3" ]] ||
		die "semver CLI smoke test failed"
}

src_install() {
	insinto /usr/lib/node_modules/${MY_PN}
	doins package.json index.js preload.js range.bnf
	doins -r bin classes functions internal ranges
	fperms +x /usr/lib/node_modules/${MY_PN}/bin/semver.js

	dobin "${FILESDIR}/semver"
	dodoc README.md
}
