# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi

DESCRIPTION="Loss functions, samplers, and trainers for metric learning in PyTorch"
HOMEPAGE="
	https://github.com/KevinMusgrave/pytorch-metric-learning
	https://pypi.org/project/pytorch-metric-learning/
"

LICENSE="Apache-2.0 BSD BSD-2 MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Version 3 uses PEP 621 metadata and ships its third-party notices.
DOCS=( README.md THIRD_PARTY_NOTICES.md )

RDEPEND="
	>=sci-ml/pytorch-2.14.0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/numpy-2.5.3[${PYTHON_USEDEP}]
	')
"
BDEPEND+="
	$(python_gen_cond_dep '
		>=dev-python/setuptools-84.0.0[${PYTHON_USEDEP}]
	')
"
