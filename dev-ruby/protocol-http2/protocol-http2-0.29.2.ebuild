# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby33 ruby34"

# Upstream gems do not include their test suites.
RUBY_FAKEGEM_RECIPE_TEST="none"
RUBY_FAKEGEM_EXTRADOC="readme.md"

inherit ruby-fakegem

DESCRIPTION="Low level implementation of the HTTP/2 protocol"
HOMEPAGE="https://github.com/socketry/protocol-http2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

ruby_add_rdepend "
	>=dev-ruby/protocol-hpack-1.4:1
	>=dev-ruby/protocol-http-0.62:0
"
