# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
# Intentional overlay relaxation: upstream's pyproject.toml declares
# maturin>=1.2,<1.14, but dev-util/maturin-1.15.0 built the abi3 wheel and
# passed the complete test suite on arm64 with Python 3.12-3.14.  amd64 remains
# unverified, so do not interpret this relaxation as amd64 validation.
DISTUTILS_USE_PEP517=maturin
PYTHON_COMPAT=( python3_{12..14} )

RUST_MIN_VER="1.83.0"
CRATES="
	cc@1.4.4
	find-msvc-tools@0.1.11
	heck@0.5.0
	httlib-hpack@0.1.3
	httlib-huffman@0.3.4
	libc@0.2.189
	once_cell@1.21.4
	portable-atomic@1.15.0
	proc-macro2@1.0.107
	pyo3-build-config@0.28.3
	pyo3-ffi@0.28.3
	pyo3-macros-backend@0.28.3
	pyo3-macros@0.28.3
	pyo3@0.28.3
	python3-dll-a@0.2.15
	quote@1.0.47
	shlex@2.0.1
	syn@2.0.119
	target-lexicon@0.13.5
	unicode-ident@1.0.24
"

inherit cargo distutils-r1 pypi

DESCRIPTION="HTTP/2 state-machine based protocol implementation"
HOMEPAGE="
	https://github.com/jawah/h2/
	https://pypi.org/project/jh2/
"
SRC_URI+=" ${CARGO_CRATE_URIS}"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+=" Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD MIT Unicode-3.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND+="
	test? (
		dev-python/hypothesis[${PYTHON_USEDEP}]
	)
"

QA_FLAGS_IGNORED="usr/lib.*/site-packages/jh2/_hazmat.*.so"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_unpack() {
	cargo_src_unpack
}
