# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=KAZUHO
DIST_VERSION=0.33
inherit perl-module

DESCRIPTION="A simple, high-performance PSGI/Plack HTTP server"
HOMEPAGE="https://metacpan.org/release/Starlet https://github.com/kazuho/Starlet"

LICENSE="|| ( Artistic GPL-1+ )"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND+="
	>=dev-perl/Parallel-Prefork-0.180.0
	>=dev-perl/Plack-0.992.0
	>=dev-perl/Server-Starter-0.60.0
"
BDEPEND+="
	${RDEPEND}
	>=virtual/perl-ExtUtils-MakeMaker-6.590.0
	test? (
		>=dev-perl/Test-TCP-2.100.0
		>=virtual/perl-Test-Simple-0.880.0
		>=dev-perl/libwww-perl-5.800.0
	)
"

src_prepare() {
	# Module::Install is bundled; Perl no longer searches the current directory.
	sed -i -e 's/use inc::Module::Install/use lib q[.];\n use inc::Module::Install/' \
		Makefile.PL || die
	perl-module_src_prepare
}
