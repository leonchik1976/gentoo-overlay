# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
# python3_15 intentionally not added yet: python-utils-r1.eclass already
# recognizes it as a valid target, and upstream 1.43.94's own
# Requires-Python (">=3.9") does not exclude it -- but ::gentoo has no
# final dev-lang/python-3.15 release (only 3.15.0_beta2..rc2/9999
# pre-releases, none installed on this host), so there is no interpreter
# here to actually build or test against. Untested, not unsupported;
# revisit once a stable dev-lang/python-3.15 exists.
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Type annotations for boto3 STS service"
HOMEPAGE="
	https://github.com/youtype/mypy_boto3_builder/
	https://pypi.org/project/mypy-boto3-sts/
	https://youtype.github.io/boto3_stubs_docs/mypy_boto3_sts/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="dev-python/botocore[${PYTHON_USEDEP}]"
