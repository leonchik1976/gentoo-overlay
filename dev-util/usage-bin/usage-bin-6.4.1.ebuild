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
S="${WORKDIR}/normalized"

LICENSE="MIT"
# Licenses of crates statically linked into the release binary (derived from
# the exact Cargo.lock and Cargo metadata at v${PV}: 268 unique package names;
# registry package licenses resolved through Cargo's crates.io index and local
# workspace licenses read from their manifests). v6.0.0 adds the BSD-3-Clause
# argh family; all other added licenses were already represented below.
#
# Not re-audited from scratch for v6.4.1 (258 unique package names): only the
# Cargo.lock diff against v6.1.1 was checked, which drops the argh/backtrace/
# miette/strum/etc. crate set (so "BSD" below may now be over-inclusive, left
# in place out of caution rather than pruned without a full re-check) and
# adds only "semver" (MIT OR Apache-2.0) and "usage-dynamic" (MIT), both
# already covered below -- so no new SPDX identifier is required, but this is
# not a substitute for a full re-audit next time the crate set changes
# substantially.
LICENSE+="
	0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 ISC LGPL-2.1
	Unicode-3.0 Unlicense ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="elibc_glibc"

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
	elibc_glibc? ( sys-libs/glibc )
"

QA_PREBUILT="usr/bin/${MY_PN}"

src_unpack() {
	default

	mkdir "${S}" || die
	cp --no-preserve=ownership -- "${WORKDIR}/${MY_PN}" "${S}" || die
	cp --no-preserve=ownership -- "${WORKDIR}/${MY_PN}.1" "${S}" || die
}

src_install() {
	dobin "${MY_PN}"

	doman "${MY_PN}".1
}
