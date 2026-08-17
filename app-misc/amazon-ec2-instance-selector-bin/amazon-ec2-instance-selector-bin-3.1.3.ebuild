# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="CLI tool and library to select the best EC2 instance types for your workload"
HOMEPAGE="https://github.com/aws/amazon-ec2-instance-selector"
SITE="https://github.com/aws/amazon-ec2-instance-selector/releases/download/v${PV}"
SRC_URI="
	amd64? ( ${SITE}/ec2-instance-selector-linux-amd64 -> ${P}-linux-amd64 )
	arm64? ( ${SITE}/ec2-instance-selector-linux-arm64 -> ${P}-linux-arm64 )
"
S="${WORKDIR}"

# Statically linked Go binary: LICENSE covers the project's own license
# plus every statically-linked dependency's license, audited directly
# against the compiled binary with dev-go/lichen: Apache-2.0 (own +
# aws-sdk-go-v2/cobra/etc.), BSD-3-Clause (-> BSD, golang.org/x/sys,
# pflag), and MIT (charmbracelet stack and others).
LICENSE="Apache-2.0 BSD MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror strip test"

QA_PREBUILT="usr/bin/ec2-instance-selector"

src_install() {
	# The fetched asset is a raw binary with no recognized archive suffix,
	# so default src_unpack skips it entirely rather than copying it into
	# WORKDIR (see PMS unpack()); fetch it straight from DISTDIR instead.
	newbin "${DISTDIR}/${P}-linux-$(usex amd64 amd64 arm64)" ec2-instance-selector
}
