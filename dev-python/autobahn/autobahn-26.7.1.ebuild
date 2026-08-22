# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# NOTE: bug #967367 - ::gentoo masked >=autobahn-25.10 (2025-12-12, upstream's
# shift to "LLM-first coding") then last-rited and removed autobahn
# (2026-08-21); no CVE or reproducible defect was ever cited. Re-added here
# at the latest upstream release to keep dev-util/buildbot installable.
# Re-evaluate upstream's release quality before bumping further.

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 optfeature pypi

DESCRIPTION="WebSocket and WAMP for Twisted and Asyncio"
HOMEPAGE="
	https://github.com/crossbario/autobahn-python/
	https://pypi.org/project/autobahn/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="test"
RESTRICT="!test? ( test )"

# Base runtime deps per pyproject.toml [project.dependencies]; the "twisted"
# extra (zope.interface, twisted, attrs) is pulled in unconditionally because
# dev-util/buildbot (the only consumer in this overlay) always needs it.
RDEPEND="
	>=dev-python/txaio-25.12.2[${PYTHON_USEDEP}]
	>=dev-python/cryptography-3.4.6[${PYTHON_USEDEP}]
	>=dev-python/cffi-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/hyperlink-21.0.0[${PYTHON_USEDEP}]
	>=dev-python/msgpack-1.0.2[${PYTHON_USEDEP}]
	>=dev-python/ujson-4.0.2[${PYTHON_USEDEP}]
	>=dev-python/cbor2-5.2.0[${PYTHON_USEDEP}]
	>=dev-python/zope-interface-5.2.0[${PYTHON_USEDEP}]
	>=dev-python/twisted-22.10.0[${PYTHON_USEDEP}]
	>=dev-python/attrs-20.3.0[${PYTHON_USEDEP}]
"
# This overlay intentionally does not package dev-python/pytrie (part of
# why ::gentoo last-rited autobahn/txaio - see the note above), so the
# "encryption" extra's >=dev-python/pytrie-0.4.0 is deliberately left out.
# pytrie is only imported by autobahn.wamp.cryptobox (WAMP-cryptobox
# payload encryption), guarded by try/except ImportError -> HAS_CRYPTOBOX
# = False; it was never in [project.dependencies] proper, in either the
# version ::gentoo last carried (24.4.2) or the version packaged here.
# dev-util/buildbot (the only consumer of this ebuild) does not use
# WAMP-cryptobox, so this limitation is inconsequential for it.
BDEPEND="
	>=dev-python/cffi-2.0.0[${PYTHON_USEDEP}]
	test? (
		${RDEPEND}
		>=dev-python/pyopenssl-20.0.1[${PYTHON_USEDEP}]
		>=dev-python/service-identity-18.1.0[${PYTHON_USEDEP}]
		>=dev-python/pynacl-1.4.0[${PYTHON_USEDEP}]
		>=dev-python/qrcode-7.3.1[${PYTHON_USEDEP}]
		>=dev-python/base58-2.1.1[${PYTHON_USEDEP}]
		>=dev-python/ecdsa-0.19.1[${PYTHON_USEDEP}]
		>=dev-python/argon2-cffi-20.1.0[${PYTHON_USEDEP}]
		>=dev-python/libpass-1.7.4[${PYTHON_USEDEP}]
		dev-python/pytest[${PYTHON_USEDEP}]
		dev-python/pytest-asyncio[${PYTHON_USEDEP}]
		dev-python/pytest-aiohttp[${PYTHON_USEDEP}]
	)
"

python_prepare_all() {
	# pyproject.toml's [project.scripts] installs the FlatBuffers compiler
	# wrapper as a bare "flatc" console script, colliding with the real
	# flatc provided by other packages (e.g. dev-libs/flatbuffers). Rename
	# only that entry point; leave autobahn's own private, bundled
	# src/autobahn/_flatc/bin/flatc binary (which the wrapper execs, and
	# which is not shipped by the sdist anyway - see below) untouched.
	sed -e 's/^flatc = /autobahn-flatc = /' -i pyproject.toml || die
	grep -q '^autobahn-flatc = "autobahn[.]_flatc:main"$' pyproject.toml ||
		die "Failed to rename the bundled flatc entry point"

	distutils-r1_python_prepare_all
}

# Building the NVX CFFI accelerator invokes a git submodule check for
# deps/flatbuffers (not shipped in the sdist) purely for a best-effort
# flatc build; that step is designed to no-op with a warning when the
# submodule is absent, no network access is required.
python_test() {
	einfo "WAMP-cryptobox payload encryption tests are skipped: dev-python/pytrie is not packaged in this overlay (see BDEPEND)"

	einfo "Testing all, cryptosign using twisted"
	local -x USE_TWISTED=true
	"${EPYTHON}" -m twisted.trial autobahn || die "Tests failed with ${EPYTHON}"
	unset USE_TWISTED

	einfo "RE-testing cryptosign and component_aio using asyncio"
	local EPYTEST_PLUGINS=( pytest-asyncio )
	local -x USE_ASYNCIO=true
	epytest --pyargs \
		autobahn.asyncio.test.test_aio_{raw,web}socket \
		autobahn.wamp.test.test_wamp_{cryptosign,component_aio}
	unset USE_ASYNCIO

	rm -f twisted/plugins/dropin.cache || die
}

pkg_postinst() {
	# autobahn/websocket/compress_brotli.py does "import brotli" on CPython
	# (brotlicffi is only imported on PyPy, which this ebuild does not
	# target); app-arch/brotli's "python" USE flag is what provides that
	# "brotli" module for CPython, there is no separate dev-python/brotli.
	optfeature "non-standard WebSocket compression support (Brotli)" \
		"app-arch/brotli[python]"
	# msgpack, ujson and cbor2 are unconditional RDEPEND (upstream made the
	# WAMP serializers hard base dependencies as of the 26.x series), so
	# there is nothing left to suggest here.
	# Covers TLS transport encryption and WAMP-cryptosign authentication only
	# (not the full "encryption" extra): WAMP-cryptobox payload encryption
	# also needs dev-python/pytrie, which this overlay does not package -
	# see BDEPEND.
	optfeature "TLS transport encryption and WAMP-cryptosign authentication" \
		"dev-python/pyopenssl dev-python/service-identity dev-python/pynacl dev-python/qrcode dev-python/base58 dev-python/ecdsa"
	optfeature "WAMP-SCRAM authentication" \
		"dev-python/argon2-cffi dev-python/libpass"

	python_foreach_impl twisted-regen-cache
}

pkg_postrm() {
	python_foreach_impl twisted-regen-cache
}
