# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{13..14} )
inherit distutils-r1 pypi

DESCRIPTION="Microsoft Azure Identity Library for Python"
HOMEPAGE="https://pypi.org/project/azure-identity/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/azure-core-1.31.0[${PYTHON_USEDEP}]
	>=dev-python/cryptography-2.5[${PYTHON_USEDEP}]
	>=dev-python/msal-1.39.0[${PYTHON_USEDEP}]
	>=dev-python/msal-extensions-1.2.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.0.0[${PYTHON_USEDEP}]
"

BDEPEND+=" >=dev-python/setuptools-77.0.3[${PYTHON_USEDEP}]"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

EPYTEST_DESELECT=(
	# The sdist omits certificate.pem and the live Azure tests need credentials.
	'tests/test_context_manager.py::test_close[CertificateCredential]'
	'tests/test_context_manager.py::test_context_manager[CertificateCredential]'
	'tests/test_context_manager.py::test_exit_args[CertificateCredential]'
	tests/test_client_secret_credential.py::test_live_multitenant_authentication
)

python_test() {
	# The global conftest requires the Azure SDK recording proxy.
	epytest --noconftest tests/test_{authority,auth_record,chained_credential,initialization,context_manager,bearer_token_provider,environment_credential,managed_identity_client,client_secret_credential}.py
}
