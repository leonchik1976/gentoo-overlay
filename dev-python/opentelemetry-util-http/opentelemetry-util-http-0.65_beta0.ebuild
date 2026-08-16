# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# New package: not present in ::gentoo or ::guru. Hard, unconditional
# (exact ==0.65b0) runtime dependency of dev-python/opentelemetry-
# instrumentation-requests, itself a direct dependency of
# dev-util/semgrep-bin. Mirrors ::guru's own packaging pattern for the
# opentelemetry-python-contrib monorepo (same tag layout as ::guru's
# dev-python/opentelemetry-instrumentation and
# dev-python/opentelemetry-instrumentation-threading), rather than
# ::nest's simpler pypi.eclass-based build of the same package, to stay
# consistent with the rest of the 0.65b0 instrumentation stack.
DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_12 python3_13 python3_14 )

inherit distutils-r1

MY_PV=${PV/_beta/b}
MY_P="opentelemetry-python-contrib-${MY_PV}"

DESCRIPTION="Web util for OpenTelemetry"
HOMEPAGE="
	https://opentelemetry.io/
	https://pypi.org/project/opentelemetry-util-http/
	https://github.com/open-telemetry/opentelemetry-python-contrib/
"
SRC_URI="
	https://github.com/open-telemetry/opentelemetry-python-contrib/archive/refs/tags/v${MY_PV}.tar.gz
		-> ${MY_P}.gh.tar.gz
"
S="${WORKDIR}/${MY_P}/util/${PN}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# upstream 0.65b0 declares no runtime Requires-Dist at all (verified
# via PyPI JSON metadata).

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
