# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=BPS
DIST_VERSION=2026.033
inherit perl-module

DESCRIPTION="A Date/Time Parsing Perl Module"

LICENSE="|| ( Artistic GPL-1+ )"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Tests use Time::Piece, shipped in core Perl since 5.9.5; perl-module
# already requires a newer Perl. No virtual/perl-Time-Piece exists.
BDEPEND+="
	>=virtual/perl-ExtUtils-MakeMaker-6.590.0
"
