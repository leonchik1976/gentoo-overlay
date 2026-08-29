# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit edo

MY_PV="v${PV}"

DESCRIPTION="Shell parser, formatter, and interpreter (POSIX/Bash/mksh)"
HOMEPAGE="https://github.com/mvdan/sh"
SRC_URI="
	amd64? ( https://github.com/mvdan/sh/releases/download/${MY_PV}/shfmt_${MY_PV}_linux_amd64 -> ${P}-linux-amd64 )
	arm64? ( https://github.com/mvdan/sh/releases/download/${MY_PV}/shfmt_${MY_PV}_linux_arm64 -> ${P}-linux-arm64 )
	man? ( https://raw.githubusercontent.com/mvdan/sh/${MY_PV}/cmd/shfmt/shfmt.1.scd -> ${P}.1.scd )
"
S="${WORKDIR}"

# Statically linked Go binary: LICENSE covers shfmt's own license (BSD)
# plus every statically-linked dependency's license, audited directly
# against the compiled binary with dev-go/lichen: BSD-3-Clause (-> BSD)
# and Apache-2.0 (google/renameio).
LICENSE="BSD Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+man"
RESTRICT="bindist mirror strip test"

BDEPEND="man? ( app-text/scdoc )"

QA_PREBUILT="usr/bin/shfmt"

src_compile() {
	# Both the binary and the .scd doc file are raw distfiles with no
	# recognized archive suffix, so default src_unpack skips copying them
	# into WORKDIR (see PMS unpack()); read them straight from DISTDIR.
	use man && edo scdoc < "${DISTDIR}/${P}.1.scd" > shfmt.1
}

src_install() {
	newbin "${DISTDIR}/${P}-linux-$(usex amd64 amd64 arm64)" shfmt
	use man && doman shfmt.1
}
