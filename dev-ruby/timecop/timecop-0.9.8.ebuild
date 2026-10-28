# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby33 ruby34"

# The gem does not include the upstream test suite.
RUBY_FAKEGEM_RECIPE_TEST="none"
RUBY_FAKEGEM_BINWRAP=""
RUBY_FAKEGEM_EXTRADOC="README.markdown"

inherit ruby-fakegem

DESCRIPTION="A gem providing time travel and time freezing capabilities"
HOMEPAGE="https://github.com/travisjeffery/timecop"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
