# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit webapp

WEBAPP_MANUAL_SLOT="yes"

DESCRIPTION="Online diagramming web application (draw.io / diagrams.net)"
HOMEPAGE="https://github.com/jgraph/drawio"
SRC_URI="https://github.com/jgraph/drawio/releases/download/v${PV}/draw.war -> ${P}.war"
S="${WORKDIR}/${P}"

# Covers the webapp's own license plus every jar bundled in WEB-INF/lib,
# audited directly by extracting each jar's META-INF/LICENSE(.txt) and/or
# Maven pom.xml <licenses> block: Apache-2.0 (cache-api, all commons-*,
# ehcache, gae-stub, gson, httpclient, httpcore, servlet-api) and MIT
# (pusher-http-java, slf4j-api).
LICENSE="Apache-2.0 MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="vhosts"

BDEPEND="app-arch/unzip"

# Upstream only publishes a prebuilt WAR release asset (with the servlet
# backend already compiled into WEB-INF/classes and its dependency jars
# in WEB-INF/lib); there is no source release to build from.
src_unpack() {
	mkdir -p "${S}" || die
	unzip -qo "${DISTDIR}/${P}.war" -d "${S}" || die
}

src_install() {
	webapp_src_preinst

	cp -R "${S}"/* "${ED}/${MY_HTDOCSDIR}" || die "cp failed"

	webapp_src_install
}
