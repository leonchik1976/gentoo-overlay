# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

MY_PV="${PV}-e8db854"

DESCRIPTION="Cursor CLI - interact with AI agents directly from your terminal"
HOMEPAGE="https://docs.cursor.com/en/cli"
SRC_URI="
	amd64? ( https://downloads.cursor.com/lab/${MY_PV}/linux/x64/agent-cli-package.tar.gz -> ${P}-x64.tar.gz )
	arm64? ( https://downloads.cursor.com/lab/${MY_PV}/linux/arm64/agent-cli-package.tar.gz -> ${P}-arm64.tar.gz )
"
S="${WORKDIR}"/dist-package

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="bindist mirror strip"

RDEPEND="
	>=net-libs/nodejs-22.1.0
	sys-apps/ripgrep
	sys-libs/glibc
	virtual/zlib
"

QA_PREBUILT="opt/cursor-agent/*"

src_install() {
	rm -r rg node || die
	if use arm64; then
		rm -r node_modules/tree-sitter-bash/prebuilds/linux-x64 || die
	fi
	sed -i 's|NODE_BIN="$SCRIPT_DIR/node"|NODE_BIN="node"|' cursor-agent || die
	sed -i 's|exec "$SCRIPT_DIR/node"|exec node|' cursor-askpass || die

	insinto /opt/${PN}
	doins -r .
	fperms +x /opt/${PN}/{${PN},cursor-askpass,cursorsandbox,crepectl}

	dosym ../${PN}/${PN} /opt/bin/${PN}
	dosym ../${PN}/${PN} /opt/bin/agent
}
