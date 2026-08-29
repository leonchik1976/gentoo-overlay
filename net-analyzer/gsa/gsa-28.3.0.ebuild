# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

MY_NODE_N="node-modules"
MY_NODE_D="node_modules"
ROLLDOWN_PV="1.1.5"
LIGHTNINGCSS_PV="1.32.0"
SWC_PV="1.15.43"

DESCRIPTION="Greenbone Security Assistant"
HOMEPAGE="https://www.greenbone.net https://github.com/greenbone/gsa"
SRC_URI="
	https://github.com/greenbone/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/greenbone/${PN}/releases/download/v${PV}/${PN}-${MY_NODE_N}-${PV}.tar.xz
	arm64? (
		https://registry.npmjs.org/@rolldown/binding-linux-arm64-gnu/-/binding-linux-arm64-gnu-${ROLLDOWN_PV}.tgz
		https://registry.npmjs.org/@rolldown/binding-linux-arm64-musl/-/binding-linux-arm64-musl-${ROLLDOWN_PV}.tgz
		https://registry.npmjs.org/lightningcss-linux-arm64-gnu/-/lightningcss-linux-arm64-gnu-${LIGHTNINGCSS_PV}.tgz
		https://registry.npmjs.org/lightningcss-linux-arm64-musl/-/lightningcss-linux-arm64-musl-${LIGHTNINGCSS_PV}.tgz
		https://registry.npmjs.org/@swc/core-linux-arm64-gnu/-/core-linux-arm64-gnu-${SWC_PV}.tgz
		https://registry.npmjs.org/@swc/core-linux-arm64-musl/-/core-linux-arm64-musl-${SWC_PV}.tgz
	)
"

LICENSE="AGPL-3+ MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
# Upstream tests are not currently run in the ebuild's offline build setup.
RESTRICT="test"

BDEPEND="
	>=net-libs/nodejs-22.0.0[npm,ssl]
"

MY_NODE_DIR="${S}/${MY_NODE_D}"

src_unpack() {
	unpack "${P}.tar.gz" "${PN}-${MY_NODE_N}-${PV}.tar.xz"

	# Upstream generates its node_modules archive on amd64, so its bundled
	# native dependencies are directly usable there. Only arm64 is missing
	# these optional Rolldown, Lightning CSS, and SWC native modules.
	if use arm64; then
		local package_name package_version target
		while read -r package_name package_version target; do
			unpack "${package_name}-${package_version}.tgz"
			if [[ ${target} == */* ]]; then
				mkdir -p "${MY_NODE_D}/${target%/*}" || die
			fi
			mv package "${MY_NODE_D}/${target}" ||
				die "failed to add ${target}"
		done <<-EOF
			binding-linux-arm64-gnu ${ROLLDOWN_PV} @rolldown/binding-linux-arm64-gnu
			binding-linux-arm64-musl ${ROLLDOWN_PV} @rolldown/binding-linux-arm64-musl
			lightningcss-linux-arm64-gnu ${LIGHTNINGCSS_PV} lightningcss-linux-arm64-gnu
			lightningcss-linux-arm64-musl ${LIGHTNINGCSS_PV} lightningcss-linux-arm64-musl
			core-linux-arm64-gnu ${SWC_PV} @swc/core-linux-arm64-gnu
			core-linux-arm64-musl ${SWC_PV} @swc/core-linux-arm64-musl
		EOF
	fi
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
		npm --offline run build || die
}

src_install() {
	insinto /usr/share/gvm/gsad/web
	doins -r build/*
}
