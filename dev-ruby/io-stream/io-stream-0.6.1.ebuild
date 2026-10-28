# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby33 ruby34"

# Upstream gems do not include their test suites.
RUBY_FAKEGEM_RECIPE_TEST="none"
RUBY_FAKEGEM_EXTRADOC="readme.md"

inherit ruby-fakegem

DESCRIPTION="Generic stream wrapper for Ruby IO instances"
HOMEPAGE="https://github.com/socketry/io-stream"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
