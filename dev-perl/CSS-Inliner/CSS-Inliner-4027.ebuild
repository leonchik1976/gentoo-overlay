# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=KAMELKEV
DIST_VERSION=4027
inherit perl-module

DESCRIPTION="Library for converting CSS <style> blocks to inline styles"

SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Upstream requires HTML::TreeBuilder>=5.03 (-> dev-perl/HTML-Tree) and
# HTML::Query>=0.09 (-> dev-perl/HTML-Query); URI and LWP carry no floor.
# See dev-perl/HTML-Query's own ebuild comment for why these are left
# unversioned rather than hand-converted from CPAN's version numbers.
RDEPEND="
	dev-perl/HTML-Query
	dev-perl/HTML-Tree
	dev-perl/URI
	dev-perl/libwww-perl
"
BDEPEND="
	${RDEPEND}
	virtual/perl-ExtUtils-MakeMaker
"
