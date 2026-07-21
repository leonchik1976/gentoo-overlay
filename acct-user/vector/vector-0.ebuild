# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit acct-user

DESCRIPTION="User for Vector"
ACCT_USER_ID=-1
ACCT_USER_GROUPS=( vector )
ACCT_USER_HOME=/var/lib/vector
ACCT_USER_HOME_PERMS=0750

KEYWORDS="~amd64 ~arm64"

acct-user_add_deps
