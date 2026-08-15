# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

MY_PN="${PN%-bin}"

DESCRIPTION="A specification for defining CLIs"
HOMEPAGE="https://usage.jdx.dev https://github.com/jdx/usage"
SRC_URI="
	amd64? (
		https://github.com/jdx/usage/releases/download/v${PV}/usage-x86_64-unknown-linux-gnu.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/jdx/usage/releases/download/v${PV}/usage-aarch64-unknown-linux-gnu.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}"

LICENSE="MIT"
# Licenses of crates statically linked into the release binary (derived from
# the exact Cargo.lock at v${PV}, all 221 unique crate names resolved via
# crates.io; 0 unresolved).
LICENSE+="
	0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 ISC LGPL-2.1
	Unicode-3.0 Unlicense ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Dynamically linked only against glibc and libgcc_s (verified via
# readelf -d on both the amd64 and arm64 release binaries); no other
# statically-embedded dependency links to a system library at runtime.
RDEPEND="
	|| (
		llvm-runtimes/libgcc
		sys-devel/gcc:*
	)
	sys-libs/glibc
"

QA_PREBUILT="usr/bin/${MY_PN}"

src_install() {
	dobin "${MY_PN}"

	doman "${MY_PN}".1
}
