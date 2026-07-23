# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Type annotations for boto3 S3 service"
HOMEPAGE="
	https://github.com/youtype/mypy_boto3_builder/
	https://pypi.org/project/mypy-boto3-s3/
	https://youtype.github.io/boto3_stubs_docs/mypy_boto3_s3/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-python/boto3[${PYTHON_USEDEP}]
	dev-python/botocore[${PYTHON_USEDEP}]
"
