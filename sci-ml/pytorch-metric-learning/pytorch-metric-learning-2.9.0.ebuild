# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1
PYPI_NO_NORMALIZE=1

inherit distutils-r1 pypi

DESCRIPTION="Loss functions, samplers, and trainers for metric learning in PyTorch"
HOMEPAGE="
	https://github.com/KevinMusgrave/pytorch-metric-learning
	https://pypi.org/project/pytorch-metric-learning/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# scipy is not in upstream's install_requires (setup.py), but
# losses/__init__.py unconditionally imports large_margin_softmax_loss.py
# (scipy.special), and nearly every loss/miner/reducer/trainer module
# imports utils/common_functions.py (scipy.stats), so it is a de facto
# hard runtime dependency for any use of the losses/miners/etc. API --
# verified against the v2.9.0 sdist on 2026-08-15.
#
# dev-python/pillow is also undeclared upstream and is needed by the
# datasets submodule (pytorch_metric_learning.datasets, for the bundled
# CUB/Cars196/SOP/iNaturalist loaders), but that submodule is not
# imported by the core losses/miners/distances/trainers API, so it is
# intentionally left out here per PG0001; install dev-python/pillow
# manually if you use pytorch_metric_learning.datasets.
RDEPEND="
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/scikit-learn[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
	')
"
