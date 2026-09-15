# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit shell-completion toolchain-funcs

MY_PN="${PN%-bin}"

DESCRIPTION="Dev tools, env vars, and tasks in one CLI"
HOMEPAGE="https://mise.jdx.dev https://github.com/jdx/mise"
SRC_URI="
	amd64? (
		https://github.com/jdx/mise/releases/download/v${PV}/mise-v${PV}-linux-x64.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://github.com/jdx/mise/releases/download/v${PV}/mise-v${PV}-linux-arm64.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}/${MY_PN}"

LICENSE="MIT"
# Licenses of crates statically linked into the release binary (derived from
# the exact Cargo.lock at v${PV}; see the dev-util/mise-bin metadata for how
# this was verified).
LICENSE+="
	0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-1 BSD-2 BZIP2
	Boost-1.0 CC0-1.0 CDLA-Permissive-2.0 GPL-2 ISC LGPL-2.1 LGPL-3 MIT-0
	MPL-2.0 Unicode-3.0 Unlicense ZLIB openssl
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="elibc_glibc"

# The release binary is dynamically linked only against glibc and libgcc_s
# (verified via readelf -d); openssl/zstd/xz are statically embedded, so no
# equivalent of the source build's BDEPEND applies here.
#
# Unlike v2026.8.10 and earlier, all three generated shell completions
# (bash, zsh, fish) are now fully self-contained: upstream replaced its
# clap-based CLI with its own "usage-argv"/"usage-rs" crates (confirmed via
# the Cargo.lock diff between v2026.8.10 and v2026.8.14 -- clap, clap_*,
# and kdl dropped; kstring, maybe-async, and the usage-* crates added), and
# each generated completion script now calls back into `mise
# __complete_word__` itself rather than shelling out to a separate "usage"
# binary. Confirmed by running `mise completion {bash,fish,zsh}` from the
# actual v2026.8.14 release asset: none of the three scripts reference an
# external "usage" command any more (the old v2026.8.10 bash script's
# `type -P usage` guard and error message are gone). The RDEPEND on
# dev-util/usage-bin this overlay carried through v2026.8.10 no longer
# applies from this version onward. The v2026.8.15 -> v2026.9.1 Cargo.lock
# diff adds only four gix-* crates (gix-macros, gix-merge, gix-note,
# gix-zlib) and send_wrapper as genuinely new crate names -- all
# "MIT OR Apache-2.0" -- plus version bumps of already-vendored crates
# (the gix/rattler/usage-* families, aws-sdk-*, mlua, tera, etc.); clap is
# still absent, the usage-* crates are still present (6.6.1), and the
# license set is unchanged (every new crate is covered by the MIT and
# Apache-2.0 tokens already listed below).
RDEPEND="
	|| (
		llvm-runtimes/libgcc
		sys-devel/gcc:*
	)
	elibc_glibc? ( sys-libs/glibc )
"

QA_PREBUILT="usr/bin/${MY_PN}"

src_compile() {
	# mise generates completions from its own embedded CLI definitions; this
	# touches no network and, under Portage's sandboxed HOME, no real user
	# configuration. As of this version all three scripts are self-contained
	# and call back into `mise` itself at completion time (see the RDEPEND
	# comment above); no external "usage" binary is required any more.
	if ! tc-is-cross-compiler; then
		./bin/"${MY_PN}" completion bash > "${T}/${MY_PN}" || die
		./bin/"${MY_PN}" completion fish > "${T}/${MY_PN}.fish" || die
		./bin/"${MY_PN}" completion zsh > "${T}/_${MY_PN}" || die
	else
		ewarn "shell completion files were skipped due to cross-compilation"
	fi
}

src_install() {
	dobin bin/"${MY_PN}"

	doman man/man1/"${MY_PN}".1

	if ! tc-is-cross-compiler; then
		dobashcomp "${T}/${MY_PN}"
		dofishcomp "${T}/${MY_PN}.fish"
		dozshcomp "${T}/_${MY_PN}"
	fi

	insinto /usr/share/fish/vendor_conf.d
	doins share/fish/vendor_conf.d/"${MY_PN}"-activate.fish

	einstalldocs
}
