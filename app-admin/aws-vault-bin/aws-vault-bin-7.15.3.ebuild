# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="Securely store and access AWS credentials (ByteNess maintained fork)"
HOMEPAGE="https://github.com/ByteNess/aws-vault"
SRC_URI="
	amd64? ( https://github.com/ByteNess/aws-vault/releases/download/v${PV}/aws-vault-linux-amd64 -> ${P}-linux-amd64 )
	arm64? ( https://github.com/ByteNess/aws-vault/releases/download/v${PV}/aws-vault-linux-arm64 -> ${P}-linux-arm64 )
"
S="${WORKDIR}"

# Statically linked Go binary. Upstream go.mod has the same module names
# as v7.13.6; shipped license texts for all 16 changed module versions
# remain within the existing MIT, Apache-2.0, BSD and BSD-2 set.
# The release strips Go build metadata, so its exact compiled module
# closure cannot be independently extracted from the binary.
LICENSE="MIT Apache-2.0 BSD BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror strip test"

QA_PREBUILT="usr/bin/aws-vault"

src_install() {
	# The fetched asset is a raw binary with no recognized archive suffix,
	# so default src_unpack skips it entirely rather than copying it into
	# WORKDIR (see PMS unpack()); fetch it straight from DISTDIR instead.
	newbin "${DISTDIR}/${P}-linux-$(usex amd64 amd64 arm64)" aws-vault
}
