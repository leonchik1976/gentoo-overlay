# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=MIXAS
DIST_VERSION=0.06
inherit perl-module

DESCRIPTION="Additional merge behaviors for Hash::Merge"

LICENSE="|| ( Artistic GPL-1+ )"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="dev-perl/Hash-Merge"
BDEPEND+=" ${RDEPEND}
	virtual/perl-Test-Simple
"
