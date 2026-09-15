# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=KAMELKEV
DIST_VERSION=0.09
inherit perl-module

DESCRIPTION="Perform jQuery-like queries on HTML::Element trees"

SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Upstream requires Badger>=0.03 and HTML::Tree>=3.23 (per MetaCPAN's
# release metadata for HTML-Query-0.09); both floors are comfortably below
# the only versions available here (dev-perl/Badger-0.16, ::gentoo's
# dev-perl/HTML-Tree-5.70.0-r1), so plain unversioned atoms are used rather
# than hand-converting CPAN's dotted version numbers into Gentoo's
# normalized three-component scheme (whose mapping is non-trivial, e.g.
# HTML-Tree's own CPAN version 5.07 is packaged in ::gentoo as 5.70.0).
RDEPEND="
	dev-perl/Badger
	dev-perl/HTML-Tree
"
BDEPEND="
	${RDEPEND}
	virtual/perl-ExtUtils-MakeMaker
"
