# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

MY_NODE_N="node-modules"
MY_NODE_D="node_modules"
ROLLUP_PV="4.49.0"
ESBUILD_PV="0.27.2"

DESCRIPTION="Greenbone Security Assistant"
HOMEPAGE="https://www.greenbone.net https://github.com/greenbone/gsa"
SRC_URI="
	https://github.com/greenbone/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/greenbone/${PN}/releases/download/v${PV}/${PN}-${MY_NODE_N}-${PV}.tar.xz
	https://registry.npmjs.org/@rollup/rollup-linux-arm64-gnu/-/rollup-linux-arm64-gnu-${ROLLUP_PV}.tgz
	https://registry.npmjs.org/@rollup/rollup-linux-arm64-musl/-/rollup-linux-arm64-musl-${ROLLUP_PV}.tgz
	https://registry.npmjs.org/@esbuild/linux-arm64/-/linux-arm64-${ESBUILD_PV}.tgz
		-> esbuild-linux-arm64-${ESBUILD_PV}.tgz
"

LICENSE="AGPL-3+ MIT"
SLOT="0"
KEYWORDS="~arm64"
# Upstream tests are not currently run in the ebuild's offline build setup.
RESTRICT="test"

BDEPEND="
	>=net-libs/nodejs-20.0.0[ssl]
	>=sys-apps/yarn-1.22
"

MY_NODE_DIR="${S}/${MY_NODE_D}"

src_unpack() {
	unpack "${P}.tar.gz" "${PN}-${MY_NODE_N}-${PV}.tar.xz"

	# Upstream's node_modules archive was generated on amd64 and omits the
	# platform-specific optional dependencies required by Rollup and esbuild.
	unpack "rollup-linux-arm64-gnu-${ROLLUP_PV}.tgz"
	mv package "${MY_NODE_D}/@rollup/rollup-linux-arm64-gnu" ||
		die "failed to add the arm64 Rollup module"

	unpack "rollup-linux-arm64-musl-${ROLLUP_PV}.tgz"
	mv package "${MY_NODE_D}/@rollup/rollup-linux-arm64-musl" ||
		die "failed to add the arm64 musl Rollup module"

	unpack "esbuild-linux-arm64-${ESBUILD_PV}.tgz"
	mv package "${MY_NODE_D}/@esbuild/linux-arm64" ||
		die "failed to add the arm64 esbuild binary"
}

src_prepare() {
	default
	# We will use pre-generated npm dependencies.
	mv "${WORKDIR}/${MY_NODE_D}" "${MY_NODE_DIR}" ||
		die "failed to move node_modules"

	# Make SVGR not traverse the path up to / looking for a configuration
	# file. This avoids EACCES if an unreadable /.config exists (bug #909731).
	echo "runtimeConfig: false" > .svgrrc.yml || die
}

src_compile() {
	NODE_ENV=production PATH="${PATH}:${MY_NODE_DIR}/.bin/" \
		yarn --offline build || die
}

src_install() {
	insinto /usr/share/gvm/gsad/web
	doins -r build/*
}
