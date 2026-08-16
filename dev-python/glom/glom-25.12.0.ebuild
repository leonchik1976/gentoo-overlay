# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# New package: not present in ::gentoo. Direct runtime dependency of
# dev-util/semgrep-bin (glom>=23.3, no upstream upper bound). Uses the
# current upstream 25.12.0 release; setup.py/setup.cfg only (no
# pyproject.toml), hence the legacy "setuptools" PEP517 backend value.
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_12 python3_13 python3_14 )

inherit distutils-r1 pypi

DESCRIPTION="A declarative object transformer and formatter, for conglomerating nested data"
HOMEPAGE="
	https://github.com/mahmoud/glom/
	https://pypi.org/project/glom/
	https://glom.readthedocs.io/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Only glom's own unconditional install_requires (setup.py); the
# "toml"/"yaml" extras (tomli/PyYAML) are for glom's own CLI input
# format support and are not pulled in here, per PG0001: semgrep only
# imports the base glom API and does not exercise glom's CLI.
RDEPEND="
	>=dev-python/boltons-19.3.0[${PYTHON_USEDEP}]
	dev-python/attrs[${PYTHON_USEDEP}]
	>=dev-python/face-20.1.1[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		dev-python/pyyaml[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest
