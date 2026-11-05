# Copyright 2021-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 optfeature pypi

DESCRIPTION="Python framework for building ML & data science web apps"
HOMEPAGE="https://github.com/plotly/dash"
SRC_URI+="
	development? (
		https://github.com/plotly/dash/archive/refs/tags/v${PV}.tar.gz
			-> ${P}.gh.tar.gz
	)
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+development"

# The upstream integration suite needs browsers, running services and packages
# not available in the repositories. Targeted offline checks are run separately.
RESTRICT="test"

# Intersect the root, renderer and component lockfile engines: lint-staged
# raises Node 22's minimum to 22.22.1; Lerna excludes the odd major versions.
RDEPEND+="
	>=dev-python/flask-1.0.4[${PYTHON_USEDEP}]
	<dev-python/flask-3.2[${PYTHON_USEDEP}]
	dev-python/importlib-metadata[${PYTHON_USEDEP}]
	dev-python/nest-asyncio[${PYTHON_USEDEP}]
	>=dev-python/plotly-5[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/retrying[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.1.1[${PYTHON_USEDEP}]
	<dev-python/werkzeug-3.2[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	>=dev-python/janus-1[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.10[${PYTHON_USEDEP}]
	dev-python/comm[${PYTHON_USEDEP}]
	development? (
		dev-python/black[${PYTHON_USEDEP}]
		>=dev-python/coloredlogs-15.0.1[${PYTHON_USEDEP}]
		>=dev-python/python-fire-0.4[${PYTHON_USEDEP}]
		>=dev-python/pyyaml-5.4.1[${PYTHON_USEDEP}]
		|| (
			( >=net-libs/nodejs-22.22.1:0[npm] <net-libs/nodejs-23:0 )
			( >=net-libs/nodejs-24:0[npm] <net-libs/nodejs-25:0 )
			( >=net-libs/nodejs-26:0[npm] <net-libs/nodejs-27:0 )
		)
	)
"

PATCHES=( "${FILESDIR}/${P}-renderer-workspace.patch" )
DOCS=( README.md "${FILESDIR}/README.gentoo" )

src_unpack() {
	# The GitHub archive is a development resource; unpacking it here would
	# overwrite the sdist, which already contains the built JupyterLab extension.
	unpack "${P}.tar.gz"
}

python_prepare_all() {
	# Upstream's sdist also contains a benchmarks Python package.
	sed -i -e 's/exclude=\["tests\*"\]/exclude=["tests*", "benchmarks*"]/' \
		setup.py || die
	if ! use development; then
		sed -i \
			-e '/"dash-generate-components = "/,+1d' \
			-e '/"renderer = /d' \
			-e '/"dash-update-components = /d' \
			setup.py || die
	fi
	distutils-r1_python_prepare_all
	sed -i \
		-e "s|@DASH_SOURCE_ARCHIVE@|${EPREFIX}/usr/share/${PN}/${P}.gh.tar.gz|" \
		dash/development/build_process.py || die
}

python_install_all() {
	distutils-r1_python_install_all
	# Keep the ::gentoo Jupyter configuration relocation.
	mv "${ED}"/usr/etc "${ED}"/etc || die
	if use development; then
		insinto /usr/share/${PN}
		doins "${DISTDIR}/${P}.gh.tar.gz"
	fi
}

pkg_postinst() {
	optfeature "HTTP compression" dev-python/flask-compress
	optfeature "async Flask callbacks" dev-python/asgiref
	optfeature "disk-backed callbacks and shared storage" \
		">=dev-python/diskcache-5.2.1 >=dev-python/multiprocess-0.70.12 >=dev-python/psutil-5.8.0 dev-python/msgspec"
	optfeature "Redis shared storage" \
		">=dev-python/redis-3.5.3 <=dev-python/redis-8.1.0 dev-python/msgspec"
	optfeature "Celery callbacks (Celery is in ::guru)" \
		">=dev-python/celery-5.1.2 <dev-python/celery-5.7 >=dev-python/redis-3.5.3 <=dev-python/redis-8.1.0 <dev-python/kombu-5.7"
	optfeature "FastAPI backend" "dev-python/fastapi dev-python/uvicorn"
	optfeature "Quart backend" dev-python/quart
	if use development; then
		elog "renderer uses a writable source tree under XDG_CACHE_HOME/dash/${PV}."
		elog "renderer --path=/path/to/dash/dash-renderer selects your own checkout."
		elog "JavaScript development commands fetch npm dependencies when invoked."
	fi
}
