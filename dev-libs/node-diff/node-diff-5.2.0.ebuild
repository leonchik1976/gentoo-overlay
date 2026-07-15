# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

MY_PN="diff"

DESCRIPTION="JavaScript text differencing implementation"
HOMEPAGE="https://github.com/kpdecker/jsdiff"
SRC_URI="https://registry.npmjs.org/${MY_PN}/-/${MY_PN}-${PV}.tgz -> ${P}.tgz"
S="${WORKDIR}/package"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="net-libs/nodejs"
BDEPEND="net-libs/nodejs"

src_compile() {
	:
}

src_test() {
	node -e '
		const diff = require("./");
		const result = diff.canonicalize({ b: 1, a: 2 });
		if (JSON.stringify(result) !== "{\"a\":2,\"b\":1}") process.exit(1);
	' || die "diff API smoke test failed"

	node --input-type=module -e '
		import { diffChars } from "diff";
		const result = diffChars("a", "b");
		if (!Array.isArray(result) || result.length === 0) process.exit(1);
	' || die "diff ESM API smoke test failed"
}

src_install() {
	insinto /usr/lib/node_modules/${MY_PN}
	doins package.json
	doins -r dist lib

	dodoc README.md release-notes.md
}
