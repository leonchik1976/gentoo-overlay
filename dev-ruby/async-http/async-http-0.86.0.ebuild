# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby33 ruby34"

# Upstream gems do not include their test suites.
RUBY_FAKEGEM_RECIPE_TEST="none"
RUBY_FAKEGEM_EXTRADOC="readme.md"

inherit ruby-fakegem

DESCRIPTION="A HTTP client and server library"
HOMEPAGE="https://github.com/socketry/async-http"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

ruby_add_rdepend "
	>=dev-ruby/async-2.10.2:2
	>=dev-ruby/async-pool-0.9:0
	>=dev-ruby/io-endpoint-0.14:0
	>=dev-ruby/io-stream-0.6:0
	>=dev-ruby/metrics-0.12:0
	>=dev-ruby/protocol-http-0.43:0
	>=dev-ruby/protocol-http1-0.28.1:0
	>=dev-ruby/protocol-http2-0.22:0
	>=dev-ruby/traces-0.10:0
"
