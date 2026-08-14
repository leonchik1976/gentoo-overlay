# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

ACCT_USER_ID=-1
ACCT_USER_GROUPS=( pcp )
ACCT_USER_HOME=/var/lib/pcp
ACCT_USER_HOME_PERMS=0755

DESCRIPTION="System user for Performance Co-Pilot"
KEYWORDS="~amd64 ~arm64"

acct-user_add_deps
