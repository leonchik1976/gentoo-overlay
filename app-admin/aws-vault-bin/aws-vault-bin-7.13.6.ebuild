# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Securely store and access AWS credentials (ByteNess maintained fork)"
HOMEPAGE="https://github.com/ByteNess/aws-vault"
SRC_URI="
	amd64? ( https://github.com/ByteNess/aws-vault/releases/download/v${PV}/aws-vault-linux-amd64 -> ${P}-linux-amd64 )
	arm64? ( https://github.com/ByteNess/aws-vault/releases/download/v${PV}/aws-vault-linux-arm64 -> ${P}-linux-arm64 )
"
S="${WORKDIR}"

# Statically linked Go binary: LICENSE covers the project's own license
# plus every statically-linked dependency's license.  The 7.13.4 binary
# was audited directly with dev-go/lichen; 7.13.5 and 7.13.6 strip the Go
# build metadata needed by lichen, but their upstream go.mod changes only
# versions of the already-audited AWS SDK modules (the full module-name set
# is byte-for-byte identical between 7.13.5 and 7.13.6) and introduces no
# modules or license families: MIT (own + many,
# including 1Password/charmbracelet/byteness stacks), Apache-2.0
# (aws-sdk-go-v2, opentelemetry, tetratelabs), BSD-3-Clause (-> BSD,
# golang.org/x/*, extism/go-sdk), and BSD-2-Clause (-> BSD-2,
# godbus/dbus, pkg/errors).
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
