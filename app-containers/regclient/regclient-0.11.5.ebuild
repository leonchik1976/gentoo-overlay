# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit go-module shell-completion toolchain-funcs

EGO_SUM=(
	"github.com/cpuguy83/go-md2man/v2 v2.0.6/go.mod"
	"github.com/davecgh/go-spew v1.1.1"
	"github.com/davecgh/go-spew v1.1.1/go.mod"
	"github.com/docker/libtrust v0.0.0-20160708172513-aabc10ec26b7"
	"github.com/docker/libtrust v0.0.0-20160708172513-aabc10ec26b7/go.mod"
	"github.com/goccy/go-yaml v1.19.2"
	"github.com/goccy/go-yaml v1.19.2/go.mod"
	"github.com/inconshreveable/mousetrap v1.1.0"
	"github.com/inconshreveable/mousetrap v1.1.0/go.mod"
	"github.com/klauspost/compress v1.18.6"
	"github.com/klauspost/compress v1.18.6/go.mod"
	"github.com/olareg/olareg v0.2.1"
	"github.com/olareg/olareg v0.2.1/go.mod"
	"github.com/opencontainers/go-digest v1.0.0"
	"github.com/opencontainers/go-digest v1.0.0/go.mod"
	"github.com/pmezard/go-difflib v1.0.0"
	"github.com/pmezard/go-difflib v1.0.0/go.mod"
	"github.com/robfig/cron/v3 v3.0.1"
	"github.com/robfig/cron/v3 v3.0.1/go.mod"
	"github.com/russross/blackfriday/v2 v2.1.0/go.mod"
	"github.com/sirupsen/logrus v1.9.4"
	"github.com/sirupsen/logrus v1.9.4/go.mod"
	"github.com/spf13/cobra v1.10.2"
	"github.com/spf13/cobra v1.10.2/go.mod"
	"github.com/spf13/pflag v1.0.9/go.mod"
	"github.com/spf13/pflag v1.0.10"
	"github.com/spf13/pflag v1.0.10/go.mod"
	"github.com/stretchr/testify v1.10.0"
	"github.com/stretchr/testify v1.10.0/go.mod"
	"github.com/sudo-bmitch/oci-digest v0.1.2"
	"github.com/sudo-bmitch/oci-digest v0.1.2/go.mod"
	"github.com/ulikunitz/xz v0.5.15"
	"github.com/ulikunitz/xz v0.5.15/go.mod"
	"github.com/yuin/gopher-lua v1.1.2"
	"github.com/yuin/gopher-lua v1.1.2/go.mod"
	"go.yaml.in/yaml/v3 v3.0.4/go.mod"
	"golang.org/x/crypto v0.52.0"
	"golang.org/x/crypto v0.52.0/go.mod"
	"golang.org/x/sys v0.45.0"
	"golang.org/x/sys v0.45.0/go.mod"
	"golang.org/x/term v0.43.0"
	"golang.org/x/term v0.43.0/go.mod"
	"gopkg.in/check.v1 v0.0.0-20161208181325-20d25e280405/go.mod"
	"gopkg.in/yaml.v3 v3.0.1"
	"gopkg.in/yaml.v3 v3.0.1/go.mod"
)
go-module_set_globals

DESCRIPTION="Docker and OCI registry client plus tooling"
HOMEPAGE="
	https://regclient.org/
	https://github.com/regclient/regclient
"
SRC_URI="
	https://github.com/regclient/regclient/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	${EGO_SUM_SRC_URI}
"

LICENSE="Apache-2.0 BSD BSD-2 CC-BY-SA-4.0 MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND+=" >=dev-lang/go-1.25.0"

src_compile() {
	local -x CGO_ENABLED=0
	local cmd
	local go_ldflags="-X github.com/regclient/regclient/internal/version.vcsTag=v${PV}"

	for cmd in regctl regsync regbot; do
		ego build -trimpath -ldflags "${go_ldflags}" -o "bin/${cmd}" "./cmd/${cmd}"
	done

	if ! tc-is-cross-compiler; then
		for cmd in regctl regsync regbot; do
			"./bin/${cmd}" completion bash > "${cmd}.bash" || die
			"./bin/${cmd}" completion zsh > "${cmd}.zsh" || die
			"./bin/${cmd}" completion fish > "${cmd}.fish" || die
		done
	fi
}

src_test() {
	local -x CGO_ENABLED=0
	local -a test_pkgs
	local pkg

	ego list ./... > "${T}"/test-pkgs || die
	while read -r pkg; do
		case ${pkg} in
			github.com/regclient/regclient|github.com/regclient/regclient/internal/regnet)
				;;
			*)
				test_pkgs+=( "${pkg}" )
				;;
		esac
	done < "${T}"/test-pkgs

	ego test "${test_pkgs[@]}"
}

src_install() {
	dobin bin/regctl bin/regsync bin/regbot

	einstalldocs
	dodoc -r docs

	docinto examples
	dodoc cmd/regbot/testdata/*.yml cmd/regsync/testdata/*.yml

	if ! tc-is-cross-compiler; then
		local cmd
		for cmd in regctl regsync regbot; do
			newbashcomp "${cmd}.bash" "${cmd}"
			newzshcomp "${cmd}.zsh" "_${cmd}"
			dofishcomp "${cmd}.fish"
		done
	fi
}
