# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit acct-user

DESCRIPTION="User for the n8n external task-runner service"
ACCT_USER_ID=-1
ACCT_USER_GROUPS=( n8n-task-runners )
ACCT_USER_HOME=/var/lib/n8n-task-runners
ACCT_USER_HOME_PERMS=0750
ACCT_USER_SHELL=/sbin/nologin

acct-user_add_deps
