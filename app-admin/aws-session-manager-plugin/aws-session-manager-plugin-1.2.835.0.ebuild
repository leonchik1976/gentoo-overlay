# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="AWS Session Manager Plugin for aws-cli"
HOMEPAGE="https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html
	https://github.com/aws/session-manager-plugin"
SRC_URI="https://github.com/aws/session-manager-plugin/archive/${PV}.tar.gz -> ${P}.tar.gz"
S=${WORKDIR}/${P#aws-}

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~arm64"

src_prepare() {
	default
	printf '%s' "${PV}" > VERSION || die "failed to set release version in VERSION"
	sed -e "s/^const Version = .*/const Version = \"${PV}\"/" \
		-i src/version/version.go || die "failed to set release version in version.go"
	sed -e '/^build-arm64/s/ checkstyle//' \
		-e 's/-s //g' -i makefile || die "failed to adjust ARM64 build target"
}

src_compile() {
	emake -j1 GO_BUILD="go build" build-arm64

	mkdir -p bin/linux_arm64 || die "failed to create ARM64 ssmcli output directory"
	(
		export GO111MODULE=auto
		export GOPATH="${S}/build/private:${S}/vendor${GOPATH:+:${GOPATH}}"
		ego build -ldflags "-w" -o bin/linux_arm64/ssmcli \
			./src/ssmcli-main/main.go
	)
}

src_install() {
	dobin bin/linux_arm64/ssmcli bin/linux_arm64_plugin/session-manager-plugin
	local DOCS=( README.md RELEASENOTES.md )
	einstalldocs

	systemd_dounit packaging/linux/ssmcli.service
}
