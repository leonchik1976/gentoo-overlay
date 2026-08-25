# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit go-module

DESCRIPTION="Diff and patch JSON, YAML and other structured data"
HOMEPAGE="https://github.com/josephburnett/jd"
SRC_URI="https://github.com/josephburnett/jd/archive/v${PV}.tar.gz -> ${P}.tar.gz"

EGO_SUM=(
	"github.com/davecgh/go-spew v1.1.1"
	"github.com/davecgh/go-spew v1.1.1/go.mod"
	"github.com/pmezard/go-difflib v1.0.0"
	"github.com/pmezard/go-difflib v1.0.0/go.mod"
	"github.com/stretchr/testify v1.11.1"
	"github.com/stretchr/testify v1.11.1/go.mod"
	"go.yaml.in/yaml/v3 v3.0.4"
	"go.yaml.in/yaml/v3 v3.0.4/go.mod"
	"gopkg.in/check.v1 v0.0.0-20161208181325-20d25e280405"
	"gopkg.in/check.v1 v0.0.0-20161208181325-20d25e280405/go.mod"
	"gopkg.in/yaml.v3 v3.0.1"
	"gopkg.in/yaml.v3 v3.0.1/go.mod"
)
go-module_set_globals

SRC_URI+=" ${EGO_SUM_SRC_URI}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# www-client/jd (an unrelated 2ch GTK browser) also installs a binary
# named jd; the two cannot coexist on the same system.
RDEPEND="!www-client/jd"

# Only go.yaml.in/yaml/v3 (MIT/Apache-2.0, satisfied by MIT) is actually
# linked into the built binary; the rest of EGO_SUM is test-only
# (github.com/stretchr/testify and its own dependencies) and is not part of
# the LICENSE calculation because it is never compiled into the final binary.

src_compile() {
	cd v2/jd || die
	ego build -ldflags="-s -w" -o "${S}"/jd .
}

src_install() {
	dobin jd
}
