# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# python3_15 is supported by upstream and dependencies, but is untested here.
PYTHON_COMPAT=( python3_{11..15} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 optfeature

MY_PN=sos
MY_P=${MY_PN}-${PV}

DESCRIPTION="Tools for gathering system configuration and diagnostic information"
HOMEPAGE="https://github.com/sosreport/sos"
SRC_URI="https://github.com/sosreport/sos/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${MY_P}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-python/packaging[${PYTHON_USEDEP}]
	dev-python/pexpect[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		dev-python/pytest-mock[${PYTHON_USEDEP}]
		dev-python/pytest-xdist[${PYTHON_USEDEP}]
	)
"

python_test() {
	epytest tests
}

python_install_all() {
	distutils-r1_python_install_all

	# setup.py installs this into a literal config/ directory, while sos uses
	# /etc/sos/sos.conf as its default configuration path.
	insinto /etc/sos
	doins sos.conf
	rm -rf "${ED}/config" || die
}

pkg_postinst() {
	optfeature "automatic archive content type detection" dev-python/python-magic
	optfeature "HTTP(S) archive uploads" dev-python/requests
	optfeature "Amazon S3 archive uploads" dev-python/boto3
	optfeature "OpenStack Swift archive uploads" dev-python/python-keystoneclient dev-python/python-swiftclient
	optfeature "FTP archive uploads" net-ftp/lftp
}
