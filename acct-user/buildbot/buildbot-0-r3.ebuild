# Copyright 2019-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit acct-user

DESCRIPTION="Buildbot program user"
ACCT_USER_ID=393
ACCT_USER_GROUPS=( buildbot )

KEYWORDS="~amd64 ~arm64"

acct-user_add_deps
