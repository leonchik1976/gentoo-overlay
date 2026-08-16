# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# New package: not present in ::gentoo. Direct runtime dependency of
# dev-util/semgrep-bin (opentelemetry-instrumentation-requests~=0.58b0,
# relaxed to the coherent 0.65b0/1.44.0 stack -- see
# dev-util/semgrep-bin's own comment on the intentional OpenTelemetry
# version relaxation). Mirrors ::guru's current 0.65b0 packaging
# pattern for the sibling dev-python/opentelemetry-instrumentation and
# dev-python/opentelemetry-instrumentation-threading packages (same
# opentelemetry-python-contrib monorepo tag, same S= layout under
# instrumentation/${PN}).
DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_12 python3_13 python3_14 )

inherit distutils-r1

MY_PV=${PV/_beta/b}
MY_P="opentelemetry-python-contrib-${MY_PV}"

OTLP_PV=1.44.0

DESCRIPTION="OpenTelemetry requests instrumentation"
HOMEPAGE="
	https://opentelemetry.io/
	https://pypi.org/project/opentelemetry-instrumentation-requests/
	https://github.com/open-telemetry/opentelemetry-python-contrib/
"
SRC_URI="
	https://github.com/open-telemetry/opentelemetry-python-contrib/archive/refs/tags/v${MY_PV}.tar.gz
		-> ${MY_P}.gh.tar.gz
"
S="${WORKDIR}/${MY_P}/instrumentation/${PN}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Upstream's exact 0.65b0 Requires-Dist (verified from the released
# wheel METADATA):
#
#   opentelemetry-api~=1.12
#   opentelemetry-instrumentation==0.65b0
#   opentelemetry-semantic-conventions==0.65b0
#   opentelemetry-util-http==0.65b0
#   requests~=2.0 ; extra == "instruments"
#
# opentelemetry-api is pinned to the coherent 1.44.0 stack rather than
# the loose upstream >=1.12 floor, matching the exact pin already used
# by ::guru's own opentelemetry-instrumentation-threading for the same
# 0.65b0/1.44.0 release train. "requests" is nominally an optional
# "instruments" extra upstream, but this package is functionally
# useless without it and dev-util/semgrep-bin already depends on
# dev-python/requests directly, so it is listed unconditionally here
# too rather than gated behind a USE flag.
#
# opentelemetry-semantic-conventions version mapping: upstream's own
# Requires-Dist for this package reports
# "opentelemetry-semantic-conventions==0.65b0" (the opentelemetry-
# python-contrib/instrumentation release train's own version number),
# but opentelemetry-semantic-conventions itself is not part of that
# contrib repo -- it ships from the separate opentelemetry-python
# (core) repo, versioned in lockstep with opentelemetry-api/-sdk as
# 1.44.0. ${OTLP_PV} is therefore used here, not ${PV}. This is not a
# guess: it is exactly what both ::gentoo (opentelemetry-exporter-
# otlp-proto-http-1.44.0 depending on ~opentelemetry-sdk-1.44.0) and
# ::guru (opentelemetry-instrumentation-0.65_beta0 itself depending on
# ~opentelemetry-semantic-conventions-1.44.0) already do for the same
# cross-repo version-train correspondence.
RDEPEND="
	~dev-python/opentelemetry-api-${OTLP_PV}[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-instrumentation-${PV}[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-semantic-conventions-${OTLP_PV}[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-util-http-${PV}[${PYTHON_USEDEP}]
	>=dev-python/requests-2.0[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
