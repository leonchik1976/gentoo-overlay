# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit go-module

DESCRIPTION="Web and API based SMTP testing tool"
HOMEPAGE="https://github.com/mailhog/MailHog"
SRC_URI="https://github.com/mailhog/MailHog/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/MailHog-${PV}"

# Includes vendored Go dependencies and GPL-2 strutil.js in the embedded UI.
LICENSE="Apache-2.0 BSD BSD-2 GPL-2 MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

src_prepare() {
	default

	# Upstream predates modules and ships its dependencies in vendor/.
	# Go 1.22 module semantics allow that layout without vendor/modules.txt;
	# this does not select an old compiler or fetch/update any dependencies.
	printf 'module github.com/mailhog/MailHog\n\ngo 1.22\n' > go.mod || die
}

src_compile() {
	GOPROXY=off GOSUMDB=off GOTOOLCHAIN=local \
		ego build -mod=vendor -trimpath -ldflags "-X main.version=${PV}" -o mailhog .
}

src_test() {
	local version
	version=$(./mailhog -version) || die
	[[ ${version} == "MailHog version: ${PV}" ]] || die "Unexpected version: ${version}"
}

src_install() {
	dobin mailhog
	dodoc README.md LICENSE.md
	dodoc -r docs
}
