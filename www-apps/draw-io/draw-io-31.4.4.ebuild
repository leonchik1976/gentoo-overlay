# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# java-pkg-2 is used only to pick a build VM. It derives that VM from the
# virtual/jdk in DEPEND, so there is no separate hard-coded VM-handle list.
inherit java-pkg-2 webapp

MY_PN="drawio"

DESCRIPTION="Online diagramming web application (draw.io / diagrams.net)"
HOMEPAGE="https://github.com/jgraph/drawio"
SRC_URI="https://github.com/jgraph/drawio/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
# GitHub's tag archive expands to drawio-${PV}, not ${P}; S is not the default.
S="${WORKDIR}/${MY_PN}-${PV}"

# Audited across the whole built WAR (src/main/webapp tree + the 15 WEB-INF/lib
# jars) for v31.4.4:
#   Apache-2.0    draw.io code, mxGraph, MathJax, DOMPurify (Apache/MPL dual),
#                 Bridge.NET, puml-themes, 13 of 15 jars
#   MIT           jQuery, crypto-js, pako, JSZip (MIT/GPL dual, MIT taken),
#                 spin.js, Rough.js, perfect-freehand, simple-peer, mermaid,
#                 WebCola, pusher-http-java, slf4j-api
#   BSD           ieee754 (bundled in simple-peer)
#   ZLIB          pako ("MIT AND Zlib")
#   EPL-2.0       elkjs
#   LGPL-2.1      libavoid-js (js/libavoid-js/LICENSE)
#   CC-BY-4.0     diagram templates (templates/LICENSE)
#   OFL-1.1       Architects Daughter font (styles/fonts)
#   drawio-icons  upstream's non-free Atlassian-use restriction on the icon /
#                 stencil / shape / img artwork (README.md, */LICENSE)
LICENSE="Apache-2.0 MIT BSD ZLIB EPL-2.0 LGPL-2.1 CC-BY-4.0 OFL-1.1 drawio-icons"
KEYWORDS="~amd64 ~arm64"

# The upstream Ant build (etc/build/build.xml) drives the Google Closure
# Compiler (etc/build/compiler.jar, Apache-2.0), which ships pre-built in the
# source tree and is used only as a build tool (::gentoo has no package for it);
# the Xml2Js helper is rebuilt from its bundled source in src_compile. Every
# Java servlet dependency is vendored in src/main/webapp/WEB-INF/lib, so the
# build is fully offline.
#
# virtual/jdk goes in DEPEND (not BDEPEND) because that is where java-pkg-2's
# depend-java-query looks when choosing the build VM. jdk-11 is the real floor:
# the vendored compiler.jar (Closure v20220502) needs >=11, and Xml2Js.java
# rebuilds cleanly on 11. app-admin/webapp-config and java-config come from the
# inherited eclasses.
DEPEND=">=virtual/jdk-11:*"
BDEPEND="dev-java/ant"

# Compile the servlets against the Java 8 API so the source build matches the
# bytecode level (major 52) of upstream's own JDK 8-built release WAR.
PATCHES=( "${FILESDIR}/${P}-javac-release-8.patch" )

pkg_setup() {
	java-pkg-2_pkg_setup
	webapp_pkg_setup
}

src_prepare() {
	default
	java-pkg-2_src_prepare
}

src_compile() {
	cd "${S}/etc/build" || die

	# Upstream ships etc/build/Xml2Js.class as Java 17 bytecode; rebuild it
	# from its source so the 'merge' target's in-process <java> call runs on
	# our (>=11) build VM instead of dying with UnsupportedClassVersionError
	# and silently leaving js/stencils.min.js unregenerated.
	"${JAVAC}" Xml2Js.java || die "compiling Xml2Js failed"

	# 'app' minifies draw.io's own JavaScript with the vendored Closure
	# Compiler; 'javac' compiles the servlets into WEB-INF/classes. Together
	# they leave src/main/webapp as the complete deployable tree.
	ant -f build.xml app javac || die "ant build failed"
}

src_install() {
	webapp_src_preinst

	cp -R "${S}"/src/main/webapp/* "${ED}/${MY_HTDOCSDIR}" || die "cp failed"

	webapp_src_install
}
