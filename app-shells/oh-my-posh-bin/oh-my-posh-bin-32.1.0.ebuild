# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="Prompt theme engine for any shell, packaged from upstream prebuilt binaries"
HOMEPAGE="https://ohmyposh.dev/ https://github.com/JanDeDobbeleer/oh-my-posh"
SRC_URI="
	amd64? ( https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${PV}/posh-linux-amd64 -> ${P}-linux-amd64 )
	arm64? ( https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${PV}/posh-linux-arm64 -> ${P}-linux-arm64 )
	https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${PV}/themes.zip -> ${P}-themes.zip
"

S="${WORKDIR}"

# MIT project; exact release binary contains 29 Go dependency modules.
# Their upstream license texts are packaged separately and listed
# in files/NOTICE.deps-${PV}.txt. BSD-3-Clause maps to Gentoo BSD.
# go.yaml.in/yaml/v3 includes both MIT and Apache-2.0 source files.
LICENSE="MIT Apache-2.0 BSD BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="app-arch/unzip app-arch/xz-utils"

QA_PREBUILT="usr/bin/oh-my-posh"

src_unpack() {
	# The arch binary is a bare ELF with no recognized archive extension;
	# default src_unpack's `unpack` helper does not copy such files into
	# ${WORKDIR} at all, so pull it from ${DISTDIR} explicitly. Only
	# themes.zip needs actual extraction.
	unpack "${P}-themes.zip"
}

src_install() {
	local upstream_arch
	case ${ARCH} in
		amd64) upstream_arch=amd64 ;;
		arm64) upstream_arch=arm64 ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac

	newbin "${DISTDIR}/${P}-linux-${upstream_arch}" oh-my-posh

	# themes.zip has no top-level directory, so its contents land directly
	# in ${WORKDIR}; glob by extension only. Most themes are .omp.json,
	# but a few (e.g. devious-diamonds, glowsticks) ship as .omp.yaml.
	insinto /usr/share/oh-my-posh/themes
	doins *.omp.json *.omp.yaml

	local notices="${T}/third-party-notices"
	mkdir -p "${notices}" || die
	tar -xJf "${FILESDIR}/${P}-third-party-notices.tar.xz" -C "${notices}" || die
	docinto third-party-notices
	dodoc -r "${notices}/."
}
