# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 optfeature pypi

DESCRIPTION="A suite of utilities for AWS Lambda functions to ease adopting best practices"
HOMEPAGE="
	https://pypi.org/project/aws-lambda-powertools/
	https://github.com/aws-powertools/powertools-lambda-python/
"

# Upstream's PyPI sdist ships no test suite, so tests are not enabled here.
LICENSE="MIT-0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-python/jmespath[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
"

pkg_postinst() {
	optfeature "X-Ray tracing support" dev-python/aws-xray-sdk
	optfeature "JSON schema validation support" dev-python/fastjsonschema
	optfeature "Parser (Pydantic) support" dev-python/pydantic
	optfeature "Pydantic-based settings support" dev-python/pydantic-settings
	optfeature "boto3-based local emulator support" dev-python/boto3
	optfeature "Redis idempotency/cache support" dev-python/redis
	optfeature "data masking support" dev-python/aws-encryption-sdk dev-python/jsonpath-ng
	optfeature "Protobuf Kafka consumer support" dev-python/protobuf
}
