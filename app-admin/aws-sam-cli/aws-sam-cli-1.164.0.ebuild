# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="CLI tool to build, test, deploy and manage AWS Serverless applications"
HOMEPAGE="
	https://github.com/aws/aws-sam-cli/
	https://docs.aws.amazon.com/serverless-application-model/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# The PyPI source distribution does not contain the upstream test suite.
RESTRICT="test"

# Upstream requests boto3[crt].  CRT support is intentionally omitted;
# standard botocore HTTP and S3 transfer implementations remain available.
#
# Upstream pins click-8.1.8, boto3-1.43.38, tomlkit-0.15.0,
# watchdog-4.0.2 and tzlocal-5.3.1, and requires rich>=14.3.3.
# Gentoo patch/minor updates within the bounds below are intentionally
# allowed; 1.164.0 was validated and built with click-8.4.2,
# boto3-1.43.53, rich-14.2.0, tomlkit-0.15.1, watchdog-6.0.0 and
# tzlocal-5.4.4.  Keep cfn-lint and docker within upstream's compatibility
# ranges.
RDEPEND="
	~dev-python/aws-lambda-builders-1.65.0[${PYTHON_USEDEP}]
	~dev-python/aws-sam-translator-1.111.0[${PYTHON_USEDEP}]
	>=dev-python/boto3-1.43.38[${PYTHON_USEDEP}]
	<dev-python/boto3-1.44[${PYTHON_USEDEP}]
	>=dev-python/boto3-stubs-1.41.0[${PYTHON_USEDEP}]
	>=dev-python/cfn-lint-1.51.3[${PYTHON_USEDEP}]
	<dev-python/cfn-lint-1.53[${PYTHON_USEDEP}]
	>=dev-python/chevron-0.12[${PYTHON_USEDEP}]
	<dev-python/chevron-1[${PYTHON_USEDEP}]
	>=dev-python/click-8.1.8[${PYTHON_USEDEP}]
	<dev-python/click-9[${PYTHON_USEDEP}]
	>=dev-python/dateparser-1.3[${PYTHON_USEDEP}]
	<dev-python/dateparser-2[${PYTHON_USEDEP}]
	>=dev-python/docker-7.1.0[${PYTHON_USEDEP}]
	<dev-python/docker-7.2[${PYTHON_USEDEP}]
	<dev-python/flask-3.2[${PYTHON_USEDEP}]
	>=dev-python/jmespath-1.1.0[${PYTHON_USEDEP}]
	<dev-python/jmespath-1.2[${PYTHON_USEDEP}]
	<dev-python/jsonschema-4.27[${PYTHON_USEDEP}]
	dev-python/mypy-boto3-apigateway[${PYTHON_USEDEP}]
	dev-python/mypy-boto3-cloudformation[${PYTHON_USEDEP}]
	dev-python/mypy-boto3-ecr[${PYTHON_USEDEP}]
	dev-python/mypy-boto3-iam[${PYTHON_USEDEP}]
	dev-python/mypy-boto3-kinesis[${PYTHON_USEDEP}]
	dev-python/mypy-boto3-lambda[${PYTHON_USEDEP}]
	dev-python/mypy-boto3-s3[${PYTHON_USEDEP}]
	dev-python/mypy-boto3-schemas[${PYTHON_USEDEP}]
	dev-python/mypy-boto3-secretsmanager[${PYTHON_USEDEP}]
	dev-python/mypy-boto3-signer[${PYTHON_USEDEP}]
	dev-python/mypy-boto3-sqs[${PYTHON_USEDEP}]
	dev-python/mypy-boto3-stepfunctions[${PYTHON_USEDEP}]
	dev-python/mypy-boto3-sts[${PYTHON_USEDEP}]
	dev-python/mypy-boto3-xray[${PYTHON_USEDEP}]
	>=dev-python/pyopenssl-25.3[${PYTHON_USEDEP}]
	<dev-python/pyopenssl-26.4[${PYTHON_USEDEP}]
	>=dev-python/python-dotenv-1.0[${PYTHON_USEDEP}]
	<dev-python/python-dotenv-1.3[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-6.0[${PYTHON_USEDEP}]
	<dev-python/pyyaml-7[${PYTHON_USEDEP}]
	dev-python/regex[${PYTHON_USEDEP}]
	>=dev-python/requests-2.32.5[${PYTHON_USEDEP}]
	<dev-python/requests-2.35.0[${PYTHON_USEDEP}]
	>=dev-python/rich-14.2.0[${PYTHON_USEDEP}]
	<dev-python/rich-15.1.0[${PYTHON_USEDEP}]
	>=dev-python/ruamel-yaml-0.19.1[${PYTHON_USEDEP}]
	<dev-python/ruamel-yaml-0.20[${PYTHON_USEDEP}]
	>=dev-python/tomlkit-0.15.0[${PYTHON_USEDEP}]
	<dev-python/tomlkit-0.16[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.4.0[${PYTHON_USEDEP}]
	<dev-python/typing-extensions-5[${PYTHON_USEDEP}]
	>=dev-python/tzlocal-5.3.1[${PYTHON_USEDEP}]
	<dev-python/tzlocal-6[${PYTHON_USEDEP}]
	>=dev-python/watchdog-4.0.2[${PYTHON_USEDEP}]
	<dev-python/watchdog-7[${PYTHON_USEDEP}]
	>=dev-util/cookiecutter-2.6[${PYTHON_USEDEP}]
	<dev-util/cookiecutter-2.8[${PYTHON_USEDEP}]
"

QA_PREBUILT="
	usr/lib/python*/site-packages/samcli/local/rapid/aws-lambda-rie-arm64
	usr/lib/python*/site-packages/samcli/local/rapid/aws-lambda-rie-x86_64
"
