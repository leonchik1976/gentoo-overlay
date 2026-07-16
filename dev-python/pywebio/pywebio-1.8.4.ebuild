# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Build interactive web applications with imperative Python code"
HOMEPAGE="
	https://github.com/pywebio/PyWebIO/
	https://pywebio.readthedocs.io/
	https://pypi.org/project/pywebio/
"

# The sdist bundles mostly MIT-licensed frontend assets.  DOMPurify is
# alternatively licensed under Apache-2.0 or MPL-2.0.  AG Grid Enterprise is
# commercial software used only when the caller supplies an enterprise key.
LICENSE="MIT || ( Apache-2.0 MPL-2.0 ) all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror"

RDEPEND="
	>=dev-python/tornado-5.0[${PYTHON_USEDEP}]
	dev-python/user-agents[${PYTHON_USEDEP}]
"

distutils_enable_tests unittest

python_test() {
	"${EPYTHON}" - <<-EOF || die
		import pywebio
		import pywebio.input
		import pywebio.output
		import pywebio.pin
		import pywebio.platform.tornado
		import pywebio.session
	EOF
}
