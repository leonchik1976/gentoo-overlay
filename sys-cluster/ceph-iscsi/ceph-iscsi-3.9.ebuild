# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# distutils-r1.eclass currently only supports EAPI 8 (see @SUPPORTED_EAPIS in
# /var/db/repos/gentoo/eclass/distutils-r1.eclass); fall back from the
# repository's preferred EAPI 9 until it does.

# Match sys-cluster/ceph's PYTHON_COMPAT: ceph-iscsi needs ceph's own
# rados/rbd cython modules, built only for whichever impls ceph enables.
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 systemd

DESCRIPTION="Configuration management and CLI tools for Ceph RBD-backed iSCSI (LIO) gateways"
HOMEPAGE="https://github.com/ceph/ceph-iscsi"
SRC_URI="https://github.com/ceph/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="test"

# test/test_group.py isn't a unittest.TestCase: it calls settings.init() and
# talks to a real Ceph cluster with pre-existing gateways/disks/clients at
# import time ("You need a working ceph iscsi environment", per its own
# comment), so it can't be collected by an automated test runner alongside
# the other three modules -- see python_test() below, which runs only
# test_chap/test_common/test_settings by name instead of discovering the
# whole test/ directory.
RESTRICT="!test? ( test )"

# rbd-target-api/-gw need a running tcmu-runner (with its rbd handler) to
# actually attach RBD-backed LUNs, and rtslib-fb to drive LIO. targetcli-fb
# is not a dependency of ceph-iscsi's own code: gwcli replaces it for
# iSCSI-gateway configuration, and where gwcli.8 mentions targetcli it's
# only as an optional tool for an administrator to inspect the local LIO
# config, not something ceph-iscsi itself invokes.
RDEPEND="
	${PYTHON_DEPS}
	dev-python/cryptography[${PYTHON_USEDEP}]
	dev-python/distro[${PYTHON_USEDEP}]
	dev-python/flask[${PYTHON_USEDEP}]
	dev-python/netifaces[${PYTHON_USEDEP}]
	dev-python/pyopenssl[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/werkzeug[${PYTHON_USEDEP}]
	dev-python/configshell-fb[${PYTHON_USEDEP}]
	>=dev-python/rtslib-fb-2.2[${PYTHON_USEDEP}]
	sys-block/tcmu-runner[rbd]
	sys-cluster/ceph[${PYTHON_USEDEP}]
"

# The three unit-test modules kept in python_test() (and everything they
# import transitively: client/target/discovery/alua/backstore/common/
# settings/utils/gateway_object.py) only reach cryptography, netifaces,
# rtslib-fb and ceph's own rados/rbd bindings -- never flask, werkzeug,
# requests, pyopenssl, distro, configshell-fb or tcmu-runner, so BDEPEND
# lists exactly that subset instead of reusing the whole of RDEPEND.
BDEPEND="
	test? (
		dev-python/cryptography[${PYTHON_USEDEP}]
		dev-python/netifaces[${PYTHON_USEDEP}]
		>=dev-python/rtslib-fb-2.2[${PYTHON_USEDEP}]
		sys-cluster/ceph[${PYTHON_USEDEP}]
	)
"

src_prepare() {
	distutils-r1_src_prepare

	# setup.py's scripts=[...] entries are only stripped of their .py suffix
	# by StripExtension, a custom `install_scripts` distutils command. That
	# command runs under legacy `setup.py install`, but distutils-r1 builds
	# and installs a wheel (PEP517), and bdist_wheel packages scripts=[...]
	# via `build_scripts`, which never calls install_scripts -- so the
	# installed scripts would keep their .py suffix and not match the
	# rbd-target-api/rbd-target-gw paths hardcoded in the systemd units and
	# gwcli.8. Rename the scripts before the build instead (dropping
	# scripts=[...] outright, rather than renaming its entries, trips a
	# distutils bug: install_scripts's build_scripts sub-step still tries to
	# copy_tree() a build/scripts-* dir that never gets created when there
	# are no scripts to build).
	#
	# The renamed scripts go into a new scripts/ directory rather than
	# being renamed in place: the desired final name "gwcli" collides with
	# the existing top-level gwcli/ package directory, and `mv foo gwcli`
	# would silently move foo *into* that directory instead of renaming it.
	mkdir scripts || die
	mv rbd-target-api.py scripts/rbd-target-api || die
	mv rbd-target-gw.py scripts/rbd-target-gw || die
	mv gwcli.py scripts/gwcli || die
	sed -i \
		-e 's/"rbd-target-gw\.py"/"scripts\/rbd-target-gw"/' \
		-e "s/'gwcli\.py'/'scripts\/gwcli'/" \
		-e "s/'rbd-target-api\.py'/'scripts\/rbd-target-api'/" \
		setup.py || die

	# ceph_iscsi_config/client.py still imports and catches the exception
	# class rtslib-fb called RTSLibNotInCFS through the 2.1.x series; it was
	# renamed to RTSLibNotInCFSError in rtslib-fb 2.2 (see rtslib/utils.py).
	# Our >=dev-python/rtslib-fb-2.2 dep guarantees the new name always
	# exists, so a straight rename (rather than a dual try/except shim) is
	# enough -- left as-is, importing client.py would raise ImportError.
	sed -i \
		-e 's/RTSLibNotInCFS\b/RTSLibNotInCFSError/g' \
		ceph_iscsi_config/client.py || die

	# rbd-target-api.py's get_ssl_context() reads werkzeug.__version__ to
	# decide whether to use SSLContext (werkzeug > 0.9) or an OpenSSL
	# fallback (werkzeug <= 0.9). Werkzeug deprecated the __version__
	# attribute in 3.0 and removed it in 3.1 (upstream points callers at
	# importlib.metadata instead), so against our dev-python/werkzeug dep
	# (3.1.8 in ::gentoo) this raises AttributeError before the version
	# comparison -- which would always take the SSLContext branch anyway,
	# since nothing remotely current is <= werkzeug 0.9.
	# Patched under its post-mv path: this runs after rbd-target-api.py was
	# already moved to scripts/rbd-target-api above.
	sed -i \
		-e '/^import werkzeug$/c\from importlib.metadata import version as _werkzeug_version' \
		-e "s/werkzeug\.__version__/_werkzeug_version('werkzeug')/" \
		scripts/rbd-target-api || die
}

python_test() {
	# Unlike BUILD_DIR (which for PEP517 packages holds only the wheel
	# build/install artifacts, not a source copy), the test phase still
	# runs with S as cwd -- see distutils-r1_run_phase's own docs.
	cd "${S}"/test || die

	# test_group.py is excluded -- see the RESTRICT comment above.
	"${EPYTHON}" -m unittest -v test_chap test_common test_settings ||
		die "tests failed under ${EPYTHON}"
}

src_install() {
	distutils-r1_src_install

	doman gwcli.8
	dodoc iscsi-gateway.cfg_sample

	systemd_dounit usr/lib/systemd/system/rbd-target-api.service
	systemd_dounit usr/lib/systemd/system/rbd-target-gw.service

	# rbd-target-api/-gw run as root and log here (see the two services'
	# 0770 root:root dirs in upstream's ceph-iscsi.spec %files).
	diropts -m 0770 -o root -g root
	keepdir /var/log/rbd-target-api /var/log/rbd-target-gw

	# LIO persistent-reservation and ALUA state. Upstream's spec keeps both
	# the /etc and /var copies because "the kernel and userspace developers
	# keep switching the dir they want to use" -- rtslib-fb 2.2.x resolves
	# its dbroot to /etc/target with a /var/target fallback (see
	# rtslib-fb's root.py: _preferred_dbroot / _default_dbroot).
	diropts -m 0755 -o root -g root
	keepdir /etc/target/pr /etc/target/alua
	keepdir /var/target/pr /var/target/alua
}
