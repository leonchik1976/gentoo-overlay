# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion

MY_PN="liquibase"

DESCRIPTION="Database schema change management tool (Community edition)"
HOMEPAGE="https://www.liquibase.com/ https://github.com/liquibase/liquibase"
SRC_URI="https://github.com/liquibase/liquibase/releases/download/v${PV}/${MY_PN}-${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}"

# PARTIAL LICENSE AUDIT: only liquibase-core's own LICENSE.txt and
# the licenses/oss/ directory it names for bundled jars (commons-*,
# snakeyaml, picocli, opencsv, h2) were checked; other bundled
# lib/*.jar content was not independently cross-checked. Not a
# complete audit of every bundled component.
#
# Verified against this exact release's own LICENSE.txt: liquibase-core
# (the Community edition) is FSL-1.1-ALv2, not Apache-2.0 -- the 4.x
# series (last release v4.33.0, 2025-07-09) is the last Apache-2.0
# release and is no longer the actively maintained line as of this
# packaging (5.0.x has continued shipping regular releases), so this
# ebuild tracks 5.x under its actual license instead. Per the FSL's
# own "Grant of Future License" clause, this specific release (made
# available 2026-08-20) additionally becomes available under
# Apache-2.0 on 2028-08-20 -- it is NOT Apache-2.0 before that date.
# Bundled third-party jars (commons-*, snakeyaml, picocli, opencsv)
# are Apache-2.0; h2 is EPL-2.0; see licenses/oss/ in the archive for
# the exact set this release ships.
LICENSE="Apache-2.0 EPL-2.0 FSL-1.1-ALv2 GPL-2-with-classpath-exception"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND=">=virtual/jre-17:*"

src_install() {
	local dest="/opt/${PN}-${SLOT}"
	local ddest="${ED}/${dest#/}"

	dodir "${dest}"
	cp -r internal lib liquibase examples ABOUT.txt LICENSE.txt \
		README.txt changelog.txt licenses "${ddest}"/ || die
	fperms +x "${dest}"/liquibase

	newbin "${FILESDIR}"/liquibase-wrapper liquibase

	newbashcomp lib/liquibase_autocomplete.sh liquibase
	newzshcomp lib/liquibase_autocomplete.zsh _liquibase

	dodoc GETTING_STARTED.txt
}
