# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

# The go.sum module list in this project's vendored gotty fork
# (pinned to a 2021-era snapshot by upstream) is deliberately kept
# small; no vendor/ directory is shipped upstream.
#
# This package uses deprecated Go dependency packaging
# (EGO_SUM/go-module_set_globals), accepted deliberately rather than
# left clean: go-module.eclass genuinely marks both
# @DEPRECATED: none -- per the eclass doc-tag parser (pkgcore's
# eclass.py: `_tag_deprecated` treats a "none" argument as
# True/deprecated-with-no-named-replacement, NOT as "not deprecated"
# -- a reading this overlay got wrong before), so `pkgcheck scan`
# correctly and currently reports DeprecatedEclassVariable and
# DeprecatedEclassFunction for this ebuild; that is not a clean scan,
# and should not be described as one. The eclass's own documented
# non-deprecated alternative is a maintainer-hosted dependency
# tarball, which this personal overlay has no hosting for. Kept
# anyway because it remains fully offline-reproducible via
# Manifest-pinned distfiles, but as an accepted, deprecated packaging
# choice, not a resolved or clean one.
EGO_SUM=(
	"github.com/BurntSushi/toml v0.3.1/go.mod"
	"github.com/NYTimes/gziphandler v1.1.1"
	"github.com/NYTimes/gziphandler v1.1.1/go.mod"
	"github.com/cespare/xxhash/v2 v2.1.1/go.mod"
	"github.com/cespare/xxhash/v2 v2.1.2"
	"github.com/cespare/xxhash/v2 v2.1.2/go.mod"
	"github.com/cpuguy83/go-md2man/v2 v2.0.0-20190314233015-f79a8a8ca69d/go.mod"
	"github.com/cpuguy83/go-md2man/v2 v2.0.1"
	"github.com/cpuguy83/go-md2man/v2 v2.0.1/go.mod"
	"github.com/creack/pty v1.1.15"
	"github.com/creack/pty v1.1.15/go.mod"
	"github.com/davecgh/go-spew v1.1.0/go.mod"
	"github.com/davecgh/go-spew v1.1.1"
	"github.com/davecgh/go-spew v1.1.1/go.mod"
	"github.com/dgryski/go-rendezvous v0.0.0-20200823014737-9f7001d12a5f"
	"github.com/dgryski/go-rendezvous v0.0.0-20200823014737-9f7001d12a5f/go.mod"
	"github.com/elazarl/go-bindata-assetfs v1.0.1"
	"github.com/elazarl/go-bindata-assetfs v1.0.1/go.mod"
	"github.com/fatih/structs v1.1.0"
	"github.com/fatih/structs v1.1.0/go.mod"
	"github.com/fsnotify/fsnotify v1.4.7/go.mod"
	"github.com/fsnotify/fsnotify v1.4.9"
	"github.com/fsnotify/fsnotify v1.4.9/go.mod"
	"github.com/go-redis/redis/v8 v8.11.3"
	"github.com/go-redis/redis/v8 v8.11.3/go.mod"
	"github.com/go-task/slim-sprig v0.0.0-20210107165309-348f09dbbbc0/go.mod"
	"github.com/golang/protobuf v1.2.0/go.mod"
	"github.com/golang/protobuf v1.4.0-rc.1/go.mod"
	"github.com/golang/protobuf v1.4.0-rc.1.0.20200221234624-67d41d38c208/go.mod"
	"github.com/golang/protobuf v1.4.0-rc.2/go.mod"
	"github.com/golang/protobuf v1.4.0-rc.4.0.20200313231945-b860323f09d0/go.mod"
	"github.com/golang/protobuf v1.4.0/go.mod"
	"github.com/golang/protobuf v1.4.2/go.mod"
	"github.com/golang/protobuf v1.5.0/go.mod"
	"github.com/golang/protobuf v1.5.2/go.mod"
	"github.com/google/go-cmp v0.3.0/go.mod"
	"github.com/google/go-cmp v0.3.1/go.mod"
	"github.com/google/go-cmp v0.4.0/go.mod"
	"github.com/google/go-cmp v0.5.5/go.mod"
	"github.com/google/go-cmp v0.5.6/go.mod"
	"github.com/gorilla/websocket v1.4.2"
	"github.com/gorilla/websocket v1.4.2/go.mod"
	"github.com/hpcloud/tail v1.0.0/go.mod"
	"github.com/nxadm/tail v1.4.4/go.mod"
	"github.com/nxadm/tail v1.4.8"
	"github.com/nxadm/tail v1.4.8/go.mod"
	"github.com/onsi/ginkgo v1.6.0/go.mod"
	"github.com/onsi/ginkgo v1.12.1/go.mod"
	"github.com/onsi/ginkgo v1.16.4"
	"github.com/onsi/ginkgo v1.16.4/go.mod"
	"github.com/onsi/gomega v1.7.1/go.mod"
	"github.com/onsi/gomega v1.10.1/go.mod"
	"github.com/onsi/gomega v1.15.0"
	"github.com/onsi/gomega v1.15.0/go.mod"
	"github.com/patrickmn/go-cache v2.1.0+incompatible"
	"github.com/patrickmn/go-cache v2.1.0+incompatible/go.mod"
	"github.com/pkg/errors v0.9.1"
	"github.com/pkg/errors v0.9.1/go.mod"
	"github.com/pmezard/go-difflib v1.0.0"
	"github.com/pmezard/go-difflib v1.0.0/go.mod"
	"github.com/russross/blackfriday/v2 v2.0.1/go.mod"
	"github.com/russross/blackfriday/v2 v2.1.0"
	"github.com/russross/blackfriday/v2 v2.1.0/go.mod"
	"github.com/shurcooL/sanitized_anchor_name v1.0.0/go.mod"
	"github.com/stretchr/objx v0.1.0/go.mod"
	"github.com/stretchr/testify v1.3.0/go.mod"
	"github.com/stretchr/testify v1.5.1"
	"github.com/stretchr/testify v1.5.1/go.mod"
	"github.com/urfave/cli/v2 v2.3.0"
	"github.com/urfave/cli/v2 v2.3.0/go.mod"
	"github.com/yuin/goldmark v1.2.1/go.mod"
	"golang.org/x/crypto v0.0.0-20190308221718-c2843e01d9a2/go.mod"
	"golang.org/x/crypto v0.0.0-20191011191535-87dc89f01550/go.mod"
	"golang.org/x/crypto v0.0.0-20200622213623-75b288015ac9/go.mod"
	"golang.org/x/mod v0.3.0/go.mod"
	"golang.org/x/net v0.0.0-20180906233101-161cd47e91fd/go.mod"
	"golang.org/x/net v0.0.0-20190404232315-eb5bcb51f2a3/go.mod"
	"golang.org/x/net v0.0.0-20190620200207-3b0461eec859/go.mod"
	"golang.org/x/net v0.0.0-20200520004742-59133d7f0dd7/go.mod"
	"golang.org/x/net v0.0.0-20201021035429-f5854403a974/go.mod"
	"golang.org/x/net v0.0.0-20210428140749-89ef3d95e781"
	"golang.org/x/net v0.0.0-20210428140749-89ef3d95e781/go.mod"
	"golang.org/x/sync v0.0.0-20180314180146-1d60e4601c6f/go.mod"
	"golang.org/x/sync v0.0.0-20190423024810-112230192c58/go.mod"
	"golang.org/x/sync v0.0.0-20201020160332-67f06af15bc9/go.mod"
	"golang.org/x/sys v0.0.0-20180909124046-d0be0721c37e/go.mod"
	"golang.org/x/sys v0.0.0-20190215142949-d0b11bdaac8a/go.mod"
	"golang.org/x/sys v0.0.0-20190412213103-97732733099d/go.mod"
	"golang.org/x/sys v0.0.0-20190904154756-749cb33beabd/go.mod"
	"golang.org/x/sys v0.0.0-20191005200804-aed5e4c7ecf9/go.mod"
	"golang.org/x/sys v0.0.0-20191120155948-bd437916bb0e/go.mod"
	"golang.org/x/sys v0.0.0-20200323222414-85ca7c5b95cd/go.mod"
	"golang.org/x/sys v0.0.0-20200930185726-fdedc70b468f/go.mod"
	"golang.org/x/sys v0.0.0-20201119102817-f84b799fce68/go.mod"
	"golang.org/x/sys v0.0.0-20210112080510-489259a85091/go.mod"
	"golang.org/x/sys v0.0.0-20210423082822-04245dca01da/go.mod"
	"golang.org/x/sys v0.0.0-20210927052749-1cf2251ac284"
	"golang.org/x/sys v0.0.0-20210927052749-1cf2251ac284/go.mod"
	"golang.org/x/term v0.0.0-20201126162022-7de9c90e9dd1/go.mod"
	"golang.org/x/text v0.3.0/go.mod"
	"golang.org/x/text v0.3.3/go.mod"
	"golang.org/x/text v0.3.6"
	"golang.org/x/text v0.3.6/go.mod"
	"golang.org/x/tools v0.0.0-20180917221912-90fa682c2a6e/go.mod"
	"golang.org/x/tools v0.0.0-20191119224855-298f0cb1881e/go.mod"
	"golang.org/x/tools v0.0.0-20201224043029-2b0845dc783e/go.mod"
	"golang.org/x/xerrors v0.0.0-20190717185122-a985d3407aa7/go.mod"
	"golang.org/x/xerrors v0.0.0-20191011141410-1b5146add898/go.mod"
	"golang.org/x/xerrors v0.0.0-20191204190536-9bdfabe68543/go.mod"
	"golang.org/x/xerrors v0.0.0-20200804184101-5ec99f83aff1/go.mod"
	"google.golang.org/protobuf v0.0.0-20200109180630-ec00e32a8dfd/go.mod"
	"google.golang.org/protobuf v0.0.0-20200221191635-4d8936d0db64/go.mod"
	"google.golang.org/protobuf v0.0.0-20200228230310-ab0ca4ff8a60/go.mod"
	"google.golang.org/protobuf v1.20.1-0.20200309200217-e05f789c0967/go.mod"
	"google.golang.org/protobuf v1.21.0/go.mod"
	"google.golang.org/protobuf v1.23.0/go.mod"
	"google.golang.org/protobuf v1.26.0-rc.1/go.mod"
	"google.golang.org/protobuf v1.26.0/go.mod"
	"gopkg.in/check.v1 v0.0.0-20161208181325-20d25e280405/go.mod"
	"gopkg.in/fsnotify.v1 v1.4.7/go.mod"
	"gopkg.in/tomb.v1 v1.0.0-20141024135613-dd632973f1e7"
	"gopkg.in/tomb.v1 v1.0.0-20141024135613-dd632973f1e7/go.mod"
	"gopkg.in/yaml.v2 v2.2.2/go.mod"
	"gopkg.in/yaml.v2 v2.2.3/go.mod"
	"gopkg.in/yaml.v2 v2.2.4/go.mod"
	"gopkg.in/yaml.v2 v2.3.0/go.mod"
	"gopkg.in/yaml.v2 v2.4.0"
	"gopkg.in/yaml.v2 v2.4.0/go.mod"
)
go-module_set_globals

DESCRIPTION="Run kubectl in a browser-based terminal"
HOMEPAGE="https://github.com/1Panel-dev/webkubectl"
SRC_URI="
	https://github.com/1Panel-dev/webkubectl/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_SUM_SRC_URI}
"

S="${WORKDIR}/${P}/gotty"

# webkubectl itself (the wrapper scripts) is Apache-2.0. The bundled
# fork of gotty and its Go dependencies are MIT/BSD/BSD-2/Apache-2.0;
# see the LICENSE file in each vendored module for details.
LICENSE="Apache-2.0 BSD BSD-2 MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	sys-apps/util-linux
	sys-cluster/kubectl
"

BDEPEND+=" >=dev-lang/go-1.18"

# Upstream's own test suite is not present in this vendored gotty
# fork's release tag in a runnable form.
RESTRICT="test"

src_compile() {
	local -x CGO_ENABLED=0
	local go_ldflags="-X main.Version=${PV}"

	ego build -trimpath -ldflags "${go_ldflags}" -o gotty .
}

src_install() {
	dobin gotty

	exeinto /usr/libexec/webkubectl
	doexe "${FILESDIR}"/start-webkubectl.sh
	doexe "${FILESDIR}"/start-session.sh
	doexe "${FILESDIR}"/init-kubectl.sh

	dodoc "${WORKDIR}"/${P}/README.md

	systemd_newunit "${FILESDIR}"/webkubectl.service webkubectl.service

	# Per-session tmpfs mountpoints (see init-kubectl.sh) are created
	# here rather than under a shared, predictable root-level path.
	diropts -m 0700
	keepdir /var/lib/webkubectl

	# Administrator-provided kubeconfig lives here (see
	# init-kubectl.sh); 0700 since the service itself runs as root and
	# reads it directly, and kubeconfigs commonly embed credentials.
	diropts -m 0700
	keepdir /etc/webkubectl
}
