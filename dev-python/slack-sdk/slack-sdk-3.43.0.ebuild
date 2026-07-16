# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Slack API Platform SDK for Python"
HOMEPAGE="
	https://docs.slack.dev/tools/python-slack-sdk/
	https://github.com/slackapi/python-slack-sdk/
	https://pypi.org/project/slack-sdk/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Upstream pins pytest <9; enable tests after pytest 9 compatibility is verified.
RESTRICT="test"
