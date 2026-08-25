# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

MY_PN=${PN%-bin}

DESCRIPTION="Diff and patch JSON, YAML and other structured data"
HOMEPAGE="https://github.com/josephburnett/jd"
SRC_URI="
	amd64? (
		https://github.com/josephburnett/${MY_PN}/releases/download/v${PV}/${MY_PN}-amd64-linux
			-> ${P}-amd64
	)
	arm64? (
		https://github.com/josephburnett/${MY_PN}/releases/download/v${PV}/${MY_PN}-arm64-linux
			-> ${P}-arm64
	)
"
S=${WORKDIR}

# Both release binaries have the same embedded Go module set.  jd itself is
# MIT-licensed; go.yaml.in/yaml/v3 contains MIT-covered libyaml ports and
# Apache-2.0-covered remaining files.  The include_web build embeds Go's
# BSD-3-Clause-licensed wasm_exec.js and a Go-built WASM payload.  lichen
# reports MIT and Apache-2.0 identically for both binaries, with no classifier
# false positives; it does not enumerate the embedded Go web support.
LICENSE="Apache-2.0 BSD MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# www-client/jd (an unrelated 2ch GTK browser) also installs /usr/bin/jd.
RDEPEND="!www-client/jd"

QA_PREBUILT="usr/bin/${MY_PN}"

src_install() {
	newbin "${DISTDIR}/${P}-${ARCH}" "${MY_PN}"
}
