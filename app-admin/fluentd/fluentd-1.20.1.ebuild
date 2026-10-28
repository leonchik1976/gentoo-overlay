# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby33 ruby34"

RUBY_FAKEGEM_GEMSPEC="${PN}.gemspec"
RUBY_FAKEGEM_EXTRAINSTALL="fluent.conf templates"

inherit ruby-fakegem

DESCRIPTION="data collector and unified logging layer (project under CNCF)"
HOMEPAGE="https://www.fluentd.org"

SRC_URI="https://github.com/fluent/fluentd/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

COMMON_DEPEND="acct-group/fluentd
	acct-user/fluentd"
DEPEND+=" ${COMMON_DEPEND}"
RDEPEND+=" ${COMMON_DEPEND}"

ruby_add_rdepend "
	>=dev-ruby/async-http-0.86:0
	>=dev-ruby/base64-0.2:0.2
	dev-ruby/bundler
	>=dev-ruby/coolio-1.4.5:0
	>=dev-ruby/csv-3.2:3
	>=dev-ruby/drb-2.2:0
	>=dev-ruby/http_parser_rb-0.5.1:0
	>=dev-ruby/json-2.21:2
	>=dev-ruby/logger-1.6:0
	>=dev-ruby/msgpack-1.3.1:0
	>=dev-ruby/net-http-0.8:0
	>=dev-ruby/ostruct-0.6:0.6
	>=dev-ruby/serverengine-2.3.2:0
	>=dev-ruby/sigdump-0.2.5:0
	>=dev-ruby/strptime-0.2.4:0
	>=dev-ruby/tzinfo-2.0:2
	>=dev-ruby/uri-1.0:1
	>=dev-ruby/webrick-1.4:0
	>=dev-ruby/zstd-ruby-1.5:1
"

ruby_add_bdepend "test? (
	>=dev-ruby/console-1.30:1
	>=dev-ruby/flexmock-2.0:0
	>=dev-ruby/rexml-3.2:3
	>=dev-ruby/rr-3.0:0
	>=dev-ruby/test-unit-3.3:2
	dev-ruby/test-unit-rr
	<dev-ruby/timecop-0.9.9
)"

all_ruby_prepare() {
	# Gentoo uses the system timezone database rather than tzinfo-data.
	# The release archive already contains the file list we need.
	sed -i \
		-e '/add_runtime_dependency("tzinfo-data"/d' \
		-e 's/__dir__/"."/' \
		-e 's/`git ls-files -z`/Dir.glob("**\/*").join("\\x0")/' \
		"${PN}.gemspec" || die

	# These tests require unpackaged optional AWS and Oj integrations.
	rm test/plugin/test_out_http.rb test/test_event_time.rb || die
	sed -i '/data("oj",/d' test/plugin/test_parser_json.rb || die

	# Avoid Bundler and release-only tasks when running the offline tests.
	sed -i \
		-e '/require "bundler\/gem_tasks"/d' \
		-e '/Rake::Task\["release:rubygem_push"\]/d' \
		Rakefile || die
}

all_ruby_install() {
	all_fakegem_install
	keepdir /var/log/fluentd
	fowners fluentd:adm /var/log/fluentd
	insinto /etc/fluent
	doins fluent.conf
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	insinto /etc/logrotate.d
	newins "${FILESDIR}"/${PN}.logrotate ${PN}
}

pkg_postinst() {
	if [[ -z "${REPLACING_VERSIONS}" ]]; then
		elog "A default configuration file has been installed in"
		elog "${EROOT}/etc/fluent/fluent.conf. You will need to edit"
		elog "this file to match your configuration."
	fi
}
