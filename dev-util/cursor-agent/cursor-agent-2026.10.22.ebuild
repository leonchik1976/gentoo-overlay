# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

MY_PV="${PV}-27dcf5f"
NODE_PV="24.22.1"

DESCRIPTION="Cursor CLI - interact with AI agents directly from your terminal"
HOMEPAGE="https://docs.cursor.com/en/cli"
SRC_URI="
	https://raw.githubusercontent.com/nodejs/node/v${NODE_PV}/LICENSE -> nodejs-${NODE_PV}-LICENSE
	amd64? ( https://downloads.cursor.com/lab/${MY_PV}/linux/x64/agent-cli-package.tar.gz -> ${P}-x64.tar.gz )
	arm64? ( https://downloads.cursor.com/lab/${MY_PV}/linux/arm64/agent-cli-package.tar.gz -> ${P}-arm64.tar.gz )
"
S="${WORKDIR}"/dist-package

LICENSE="all-rights-reserved"
# Retained Node runtime and its bundled third-party components; see its LICENSE.
LICENSE+=" Apache-2.0 BlueOak-1.0.0 BSD BSD-2 ISC MIT Unicode-3.0 ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror strip"

RDEPEND="
	sys-apps/ripgrep
	amd64? ( >=sys-libs/glibc-2.28 )
	arm64? ( >=sys-libs/glibc-2.34 )
	virtual/zlib
"

QA_PREBUILT="opt/cursor-agent/*"

src_install() {
	# Native addons include NODE_MODULE_VERSION 137. Keep the matching upstream
	# Node 24 runtime and launchers, which select it by absolute package path.
	rm -r rg || die
	if use arm64; then
		rm -r node_modules/tree-sitter-bash/prebuilds/linux-x64 || die
	fi

	insinto /opt/${PN}
	doins -r .
	fperms +x /opt/${PN}/{${PN},cursor-askpass,cursorsandbox,crepectl,node}

	dosym ../${PN}/${PN} /opt/bin/${PN}
	dosym ../${PN}/${PN} /opt/bin/agent

	newdoc "${DISTDIR}/nodejs-${NODE_PV}-LICENSE" node-LICENSE
}
