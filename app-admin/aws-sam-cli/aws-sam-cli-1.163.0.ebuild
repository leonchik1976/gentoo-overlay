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
RDEPEND="
	dev-python/aws-lambda-builders[${PYTHON_USEDEP}]
	dev-python/aws-sam-translator[${PYTHON_USEDEP}]
	dev-python/boto3[${PYTHON_USEDEP}]
	dev-python/boto3-stubs[${PYTHON_USEDEP}]
	dev-python/cfn-lint[${PYTHON_USEDEP}]
	dev-python/chevron[${PYTHON_USEDEP}]
	dev-python/click[${PYTHON_USEDEP}]
	dev-python/dateparser[${PYTHON_USEDEP}]
	dev-python/docker[${PYTHON_USEDEP}]
	dev-python/flask[${PYTHON_USEDEP}]
	dev-python/jmespath[${PYTHON_USEDEP}]
	dev-python/jsonschema[${PYTHON_USEDEP}]
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
	dev-python/pyopenssl[${PYTHON_USEDEP}]
	dev-python/python-dotenv[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/regex[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/rich[${PYTHON_USEDEP}]
	dev-python/ruamel-yaml[${PYTHON_USEDEP}]
	dev-python/tomlkit[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
	dev-python/tzlocal[${PYTHON_USEDEP}]
	dev-python/watchdog[${PYTHON_USEDEP}]
	dev-util/cookiecutter[${PYTHON_USEDEP}]
"

QA_PREBUILT="
	usr/lib/python*/site-packages/samcli/local/rapid/aws-lambda-rie-arm64
	usr/lib/python*/site-packages/samcli/local/rapid/aws-lambda-rie-x86_64
"
