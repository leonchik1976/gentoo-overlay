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
# the exact Cargo.lock at v${PV}: 263 package records, 245 unique crate
# names, all resolved via crates.io; 0 unresolved). v5.1.0 added an async
# runtime (tokio, futures) and MCP server support (rmcp) versus 4.0.0,
# introducing 21 new unique crate names; every one of them resolves to a
# license already covered below (MIT, Apache-2.0, or Unlicense), so no new
# SPDX tokens were needed.
LICENSE+="
	0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 ISC LGPL-2.1
	Unicode-3.0 Unlicense ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Dynamically linked only against glibc-provided libraries and libgcc_s
# (verified via readelf -d on the amd64 release binary): libc.so.6,
# libm.so.6, libdl.so.2, libpthread.so.0, and librt.so.1 are satisfied by
# sys-libs/glibc; libgcc_s.so.1 is satisfied separately by
# llvm-runtimes/libgcc or sys-devel/gcc, hence the || ( ) block below. No
# other statically-embedded dependency links to a system library at runtime.
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
