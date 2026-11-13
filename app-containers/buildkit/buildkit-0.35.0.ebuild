# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-env go-module systemd

DESCRIPTION="Concurrent, cache-efficient, and Dockerfile-agnostic builder toolkit"
HOMEPAGE="https://github.com/moby/buildkit"
SRC_URI="https://github.com/moby/buildkit/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

# Includes licenses of vendored dependencies.
LICENSE="Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
# Upstream integration tests require running containers and privileged workers.
RESTRICT="test"

RDEPEND="
	app-containers/runc
	app-misc/ca-certificates
	dev-vcs/git[curl]
	net-misc/openssh
"
BDEPEND+=" >=dev-lang/go-1.26.8"

src_prepare() {
	default
	sed -i 's:/usr/local/bin/:/usr/bin/:' \
		examples/systemd/system/buildkit.service || die
}

src_compile() {
	local ldflags="-X github.com/moby/buildkit/version.Version=v${PV}"
	ldflags+=" -X github.com/moby/buildkit/version.Package=github.com/moby/buildkit"
	# Match upstream's pure-Go release build; dependencies are vendored.
	export CGO_ENABLED=0 GOTOOLCHAIN=local
	go-env_set_compile_environment
	ego build -mod=vendor -tags grpcnotrace -ldflags "${ldflags}" -o bin/buildctl ./cmd/buildctl
	ego build -mod=vendor -tags 'osusergo netgo static_build seccomp grpcnotrace' \
		-ldflags "${ldflags}" -o bin/buildkitd ./cmd/buildkitd
}

src_install() {
	dobin bin/buildctl bin/buildkitd
	systemd_dounit examples/systemd/system/buildkit.{service,socket}
	newinitd "${FILESDIR}/buildkit.initd" buildkit
	local license
	while IFS= read -r -d '' license; do
		docinto "third-party-licenses/${license%/*}"
		dodoc "${license}"
	done < <(find vendor -type f \( -name 'LICENSE*' -o -name NOTICE \) ! -name '*.docs' -print0)
	docinto .
	dodoc README.md
	dodoc -r docs
}
