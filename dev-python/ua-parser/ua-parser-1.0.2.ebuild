# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

UAP_CORE_COMMIT=383604dfd6c7518c152e3bd9b7eda67662b1b343

DESCRIPTION="Official Python implementation of the User Agent String Parser"
HOMEPAGE="
	https://github.com/ua-parser/uap-python/
	https://uap-python.readthedocs.io/
	https://pypi.org/project/ua-parser/
"
SRC_URI+="
	test? (
		https://github.com/ua-parser/uap-core/archive/${UAP_CORE_COMMIT}.tar.gz
			-> uap-core-${UAP_CORE_COMMIT}.gh.tar.gz
	)
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="dev-python/ua-parser-builtins[${PYTHON_USEDEP}]"
BDEPEND="
	dev-python/pyyaml[${PYTHON_USEDEP}]
	test? (
		${RDEPEND}
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_unpack() {
	default

	if use test; then
		mv "${WORKDIR}"/uap-core-"${UAP_CORE_COMMIT}" "${S}"/uap-core ||
			die
	fi
}
