# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit acct-user

DESCRIPTION="User for OpenSearch"
KEYWORDS="~amd64 ~arm64"
ACCT_USER_ID=-1
ACCT_USER_GROUPS=( opensearch )
ACCT_USER_HOME=/var/lib/opensearch
ACCT_USER_HOME_PERMS=0750

acct-user_add_deps
