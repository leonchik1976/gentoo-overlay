# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# CRATES generated from the upstream Cargo.lock at tag v0.9.6 (manually,
# pycargoebuild is not available on this system; parsed directly from
# Cargo.lock's [[package]] entries).
#
# Packaged in addition to (not instead of) gui-apps/cauldron-1.0.0, which is
# package.masked: v1.0.0 pins gtk4-rs 0.11.x, whose gsk4 bindings require
# gtk4 >= 4.21 (GNOME's unstable dev series; ::gentoo tops out at 4.20.4).
# v0.9.6 pins gtk4-rs 0.10.3, which only requires gtk4 >= 4.0.0 (base,
# unconditional -- verified against the actual crate's
# [package.metadata.system-deps.gtk4] in its Cargo.toml) and libadwaita-sys
# 0.8.1, which only requires libadwaita >= 1 (base, unconditional). Both are
# satisfied by currently-available ::gentoo packages. Verified with a real
# `meson setup && ninja` build in scratch space against this system's
# installed gui-libs/gtk-4.20.4 and gui-libs/libadwaita-1.8.7 (outside the
# Portage sandbox, using system cargo/rustc directly, not via emerge) --
# produced a working x86_64 ELF release binary.

EAPI=8

CRATES="
	aho-corasick@1.1.3
	android_system_properties@0.1.5
	anyhow@1.0.102
	assert-json-diff@2.0.2
	autocfg@1.3.0
	aws-lc-rs@1.15.4
	aws-lc-sys@0.37.0
	base64@0.22.1
	bitflags@2.10.0
	block@0.1.6
	block-buffer@0.10.4
	bumpalo@3.16.0
	bytes@1.11.1
	cairo-rs@0.21.5
	cairo-sys-rs@0.21.5
	cc@1.2.55
	cesu8@1.1.0
	cfg_aliases@0.2.1
	cfg-expr@0.15.8
	cfg-if@1.0.0
	chrono@0.4.44
	cmake@0.1.57
	colored@3.0.0
	combine@4.6.7
	core-foundation@0.10.1
	core-foundation@0.9.4
	core-foundation-sys@0.8.6
	cpufeatures@0.2.12
	crypto-common@0.1.6
	cssparser@0.36.0
	cssparser-macros@0.6.1
	derive_more@2.1.1
	derive_more-impl@2.1.1
	digest@0.10.7
	displaydoc@0.2.5
	dtoa@1.0.11
	dtoa-short@0.3.5
	dunce@1.0.5
	ego-tree@0.10.0
	encoding_rs@0.8.34
	entities@1.0.1
	equivalent@1.0.1
	escaper@0.1.1
	fastrand@2.3.0
	field-offset@0.3.6
	find-msvc-tools@0.1.9
	flume@0.12.0
	fmt-cmp@0.1.2
	fnv@1.0.7
	form_urlencoded@1.2.2
	fragile@2.0.1
	fs_extra@1.3.0
	futf@0.1.5
	futures@0.3.31
	futures-channel@0.3.31
	futures-core@0.3.31
	futures-executor@0.3.31
	futures-io@0.3.31
	futures-macro@0.3.31
	futures-sink@0.3.31
	futures-task@0.3.31
	futures-util@0.3.31
	gdk4@0.10.3
	gdk4-sys@0.10.3
	gdk-pixbuf@0.21.5
	gdk-pixbuf-sys@0.21.5
	generic-array@0.14.7
	getopts@0.2.24
	getrandom@0.2.15
	getrandom@0.3.4
	gettext-rs@0.7.7
	gettext-sys@0.21.3
	gio@0.21.5
	gio-sys@0.21.5
	glib@0.21.5
	glib-macros@0.21.5
	glib-sys@0.21.5
	gobject-sys@0.21.5
	graphene-rs@0.21.5
	graphene-sys@0.21.5
	gsk4@0.10.3
	gsk4-sys@0.10.3
	gtk4@0.10.3
	gtk4-macros@0.10.3
	gtk4-sys@0.10.3
	h2@0.4.4
	hashbrown@0.16.1
	heck@0.5.0
	hmac@0.12.1
	html5ever@0.36.1
	html-escape@0.2.13
	http@1.1.0
	httparse@1.10.0
	http-body@1.0.0
	http-body-util@0.1.3
	httpdate@1.0.3
	hyper@1.6.0
	hyper-rustls@0.27.2
	hyper-util@0.1.14
	iana-time-zone@0.1.60
	iana-time-zone-haiku@0.1.2
	icu_collections@1.5.0
	icu_locid@1.5.0
	icu_locid_transform@1.5.0
	icu_locid_transform_data@1.5.0
	icu_normalizer@1.5.0
	icu_normalizer_data@1.5.0
	icu_properties@1.5.1
	icu_properties_data@1.5.0
	icu_provider@1.5.0
	icu_provider_macros@1.5.0
	idna@1.1.0
	idna_adapter@1.2.0
	indexmap@2.12.1
	ipnet@2.9.0
	iri-string@0.7.8
	is-docker@0.2.0
	is-wsl@0.4.0
	itoa@1.0.11
	jni@0.21.1
	jni-sys@0.3.0
	jobserver@0.1.32
	js-sys@0.3.87
	lazy_static@1.4.0
	libadwaita@0.8.1
	libadwaita-sys@0.8.1
	libc@0.2.178
	libxml@0.3.3
	litemap@0.7.4
	locale_config@0.3.0
	lock_api@0.4.14
	log@0.4.21
	lru-slab@0.1.2
	mac@0.1.1
	malloc_buf@0.0.6
	markup5ever@0.36.1
	memchr@2.7.6
	memoffset@0.9.1
	mime@0.3.17
	mio@1.0.3
	mockito@1.7.2
	new_debug_unreachable@1.0.6
	nu-ansi-term@0.50.1
	num-traits@0.2.19
	oauth1-request@0.6.1
	oauth1-request-derive@0.5.1
	oauth-credentials@0.3.0
	objc@0.2.7
	objc-foundation@0.1.1
	objc_id@0.1.1
	once_cell@1.21.3
	open@5.3.3
	openssl-probe@0.2.1
	pango@0.21.5
	pango-sys@0.21.5
	parking_lot@0.12.5
	parking_lot_core@0.9.12
	pathdiff@0.2.1
	percent-encoding@2.3.2
	phf@0.13.1
	phf_codegen@0.13.1
	phf_generator@0.13.1
	phf_macros@0.13.1
	phf_shared@0.13.1
	pin-project-lite@0.2.14
	pin-utils@0.1.0
	pkg-config@0.3.32
	ppv-lite86@0.2.17
	precomputed-hash@0.1.1
	proc-macro2@1.0.104
	proc-macro-crate@3.4.0
	proc-macro-error@1.0.4
	proc-macro-error-attr@1.0.4
	quinn@0.11.9
	quinn-proto@0.11.13
	quinn-udp@0.5.14
	quote@1.0.36
	rand@0.8.5
	rand@0.9.2
	rand_chacha@0.3.1
	rand_chacha@0.9.0
	rand_core@0.6.4
	rand_core@0.9.3
	redox_syscall@0.5.18
	r-efi@5.3.0
	regex@1.12.3
	regex-automata@0.4.14
	regex-syntax@0.8.5
	relm4@0.10.1
	relm4-css@0.10.1
	relm4-macros@0.10.1
	reqwest@0.13.2
	ring@0.17.14
	rustc-hash@2.1.1
	rustc_version@0.4.0
	rust-embed@8.11.0
	rust-embed-impl@8.11.0
	rust-embed-utils@8.11.0
	rustls@0.23.36
	rustls-native-certs@0.8.3
	rustls-pki-types@1.12.0
	rustls-platform-verifier@0.6.2
	rustls-platform-verifier-android@0.1.1
	rustls-webpki@0.103.9
	rustversion@1.0.20
	ryu@1.0.18
	same-file@1.0.6
	schannel@0.1.23
	scopeguard@1.2.0
	scraper@0.25.0
	security-framework@3.5.1
	security-framework-sys@2.15.0
	selectors@0.33.0
	semver@1.0.23
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_json@1.0.149
	serde_spanned@0.6.5
	serde_urlencoded@0.7.1
	servo_arc@0.4.3
	sha1@0.10.6
	sha2@0.10.8
	sharded-slab@0.1.7
	shlex@1.3.0
	similar@2.7.0
	siphasher@1.0.1
	slab@0.4.9
	smallvec@1.15.1
	socket2@0.5.10
	socket2@0.6.1
	spin@0.9.8
	stable_deref_trait@1.2.0
	string_cache@0.9.0
	string_cache_codegen@0.6.1
	subtle@2.5.0
	syn@2.0.112
	sync_wrapper@1.0.1
	synstructure@0.13.1
	system-configuration@0.6.1
	system-configuration-sys@0.6.0
	system-deps@7.0.1
	target-lexicon@0.12.14
	temp-dir@0.1.13
	tendril@0.4.3
	thiserror@1.0.60
	thiserror@2.0.11
	thiserror-impl@1.0.60
	thiserror-impl@2.0.11
	thread_local@1.1.8
	tinystr@0.7.6
	tinyvec@1.10.0
	tinyvec_macros@0.1.1
	tokio@1.49.0
	tokio-macros@2.6.0
	tokio-rustls@0.26.0
	tokio-util@0.7.11
	toml@0.8.12
	toml_datetime@0.6.5
	toml_datetime@0.7.5+spec-1.1.0
	toml_edit@0.22.12
	toml_edit@0.23.10+spec-1.0.0
	toml_parser@1.0.6+spec-1.1.0
	tower@0.5.2
	tower-http@0.6.8
	tower-layer@0.3.3
	tower-service@0.3.3
	tracing@0.1.44
	tracing-attributes@0.1.31
	tracing-core@0.1.36
	tracing-log@0.2.0
	tracing-subscriber@0.3.22
	try-lock@0.2.5
	typenum@1.17.0
	unic-char-property@0.9.0
	unic-char-range@0.9.0
	unic-common@0.9.0
	unic-emoji-char@0.9.0
	unicode-ident@1.0.12
	unicode-width@0.2.2
	unic-ucd-version@0.9.0
	untrusted@0.9.0
	url@2.5.8
	urlencoding@2.1.3
	utf16_iter@1.0.5
	utf-8@0.7.6
	utf8_iter@1.0.4
	utf8-width@0.1.8
	valuable@0.1.0
	vcpkg@0.2.15
	version_check@0.9.4
	version-compare@0.2.0
	walkdir@2.5.0
	want@0.3.1
	wasi@0.11.0+wasi-snapshot-preview1
	wasip2@1.0.1+wasi-0.2.4
	wasm-bindgen@0.2.110
	wasm-bindgen-futures@0.4.60
	wasm-bindgen-macro@0.2.110
	wasm-bindgen-macro-support@0.2.110
	wasm-bindgen-shared@0.2.110
	wasm-streams@0.5.0
	web_atoms@0.2.0
	webpki-root-certs@1.0.6
	web-sys@0.3.87
	web-time@1.1.0
	winapi@0.3.9
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.9
	winapi-x86_64-pc-windows-gnu@0.4.0
	windows_aarch64_gnullvm@0.42.2
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_gnullvm@0.53.1
	windows_aarch64_msvc@0.42.2
	windows_aarch64_msvc@0.52.6
	windows_aarch64_msvc@0.53.1
	windows-core@0.52.0
	windows_i686_gnu@0.42.2
	windows_i686_gnu@0.52.6
	windows_i686_gnu@0.53.1
	windows_i686_gnullvm@0.52.6
	windows_i686_gnullvm@0.53.1
	windows_i686_msvc@0.42.2
	windows_i686_msvc@0.52.6
	windows_i686_msvc@0.53.1
	windows-link@0.1.3
	windows-link@0.2.1
	windows-registry@0.5.3
	windows-result@0.3.4
	windows-strings@0.4.2
	windows-sys@0.45.0
	windows-sys@0.52.0
	windows-sys@0.60.2
	windows-sys@0.61.2
	windows-targets@0.42.2
	windows-targets@0.52.6
	windows-targets@0.53.5
	windows_x86_64_gnu@0.42.2
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnu@0.53.1
	windows_x86_64_gnullvm@0.42.2
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_gnullvm@0.53.1
	windows_x86_64_msvc@0.42.2
	windows_x86_64_msvc@0.52.6
	windows_x86_64_msvc@0.53.1
	winnow@0.6.8
	winnow@0.7.14
	wit-bindgen@0.46.0
	write16@1.0.0
	writeable@0.5.5
	yoke@0.7.5
	yoke-derive@0.7.5
	zerofrom@0.1.5
	zerofrom-derive@0.1.5
	zeroize@1.8.1
	zerovec@0.10.4
	zerovec-derive@0.10.3
	zmij@1.0.0
"

# article_scraper is a workspace member fetched straight from its upstream
# git repository (not published to crates.io); pin it via GIT_CRATES so
# cargo.eclass fetches and vendors it offline like every other dependency.
declare -A GIT_CRATES=(
	[article_scraper]="https://gitlab.com/news-flash/article_scraper;20604bece0f68d371f3b9b1368aac5c7933344cc;article_scraper-%commit%/article_scraper"
)

inherit cargo gnome2-utils meson xdg

# Requires builder-provided Instapaper application credentials;
# approval is needed when accounts other than the application owner's are used.
# Set CAULDRON_CONSUMER_KEY / CAULDRON_CONSUMER_SECRET; see src_configure.
DESCRIPTION="Native GNOME/GTK4 client for Instapaper"
HOMEPAGE="
	https://github.com/dottorblaster/cauldron
	https://flathub.org/apps/it.dottorblaster.cauldron
"
SRC_URI="
	https://github.com/dottorblaster/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"

LICENSE="Apache-2.0"
# Dependent crate licenses
LICENSE+="
	Apache-2.0-with-LLVM-exceptions BSD CDLA-Permissive-2.0 GPL-3+ ISC MIT
	MPL-2.0 openssl Unicode-3.0 Unicode-DFS-2016
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# config.rs.in compiles CONSUMER_KEY/CONSUMER_SECRET directly into the
# resulting binary in plaintext. A binary package (quickpkg, FEATURES=buildpkg,
# a binhost, ...) built from this ebuild would therefore embed and redistribute
# the builder's own private Instapaper OAuth credentials to anyone who
# installs that binpkg -- refuse to let such a binary be redistributed.
RESTRICT="bindist"

# Version floors below are NOT this package's own unconditional minimums --
# they are derived from the actual Cargo features enabled across the
# resolved dependency graph. Cauldron itself depends on
# relm4 = { features = ["libadwaita", "gnome_48"] }; relm4's gnome_48
# feature cascades as gnome_48 -> gtk/gnome_48 -> gtk4-rs's v4_18 (real
# pkg-config requirement "4.18") and gnome_48 -> adw/v1_7 -> libadwaita-rs's
# v1_7 ("1.7"), and (via the inherited gnome_46 base) cairo-rs/v1_16
# ("1.16"), pango/v1_52 ("1.52"), gdk-pixbuf/v2_42 ("2.42"). gnome_48 also
# cascades to gio/v2_84 ("2.84"), i.e. dev-libs/glib. Traced directly from
# each crate's own [package.metadata.system-deps] table at the exact
# versions pinned in this ebuild's CRATES (relm4-0.10.1, gtk4-sys-0.10.3,
# libadwaita-sys-0.8.1, gio-sys-0.21.5), not assumed from crate version
# numbers. The unconditional/undecorated base each crate falls back to
# without any version feature enabled (e.g. gtk4 "4.0.0") is NOT what this
# build actually requires -- using it as DEPEND would let this ebuild
# install against a GTK4 too old for the API surface relm4 actually calls.
RDEPEND="
	>=dev-libs/glib-2.84
	dev-libs/libxml2
	>=gui-libs/gtk-4.18:4
	>=gui-libs/libadwaita-1.7:1
	media-libs/graphene
	>=x11-libs/cairo-1.16
	>=x11-libs/gdk-pixbuf-2.42
	>=x11-libs/pango-1.52
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-libs/glib
	sys-devel/gettext
	virtual/pkgconfig
"

PATCHES=( "${FILESDIR}/${PN}-fix-meson-cargo-build-chain.patch" )

# Rust
QA_FLAGS_IGNORED="usr/bin/${PN}"

DOCS=( README.md )

# Instapaper's OAuth API requires a consumer key/secret compiled into the
# client for sign-in to work. Upstream's own Flathub build embeds a
# hardcoded pair directly in its public flatpak manifest (verified:
# https://github.com/flathub/it.dottorblaster.cauldron/blob/master/it.dottorblaster.cauldron.json
# config-opts, -Dconsumer_key/-Dconsumer_secret) -- this ebuild does not
# reuse that pair. Building requires CAULDRON_CONSUMER_KEY /
# CAULDRON_CONSUMER_SECRET from your own Instapaper application: register
# and get it approved at
# https://www.instapaper.com/main/request_oauth_consumer_token (a newly
# registered application starts in "Owner Only" mode and must be submitted
# for review before it works for accounts other than the registrant's own).
# Set both in your environment (e.g. /etc/portage/env) before emerging.
src_configure() {
	# Building without credentials would silently produce a binary that
	# installs fine but can never sign in, so refuse to configure instead.
	# Checked here, not in pkg_pretend, since pkg_pretend is a separate,
	# earlier invocation that doesn't consume these variables.
	if [[ -z ${CAULDRON_CONSUMER_KEY} || -z ${CAULDRON_CONSUMER_SECRET} ]]; then
		eerror "CAULDRON_CONSUMER_KEY and/or CAULDRON_CONSUMER_SECRET are unset."
		eerror "Cauldron needs its own Instapaper OAuth consumer key/secret"
		eerror "compiled in, or sign-in will never work. Request a pair at:"
		eerror "  https://www.instapaper.com/main/request_oauth_consumer_token"
		eerror "then set both variables (e.g. in /etc/portage/env/${CATEGORY}/${PN})"
		eerror "and re-run emerge."
		die "CAULDRON_CONSUMER_KEY / CAULDRON_CONSUMER_SECRET not set"
	fi

	local emesonargs=(
		-Dprofile=default
		-Dsandboxed-build=false
		-Dconsumer_key="${CAULDRON_CONSUMER_KEY}"
		-Dconsumer_secret="${CAULDRON_CONSUMER_SECRET}"
	)
	meson_src_configure
}

src_compile() {
	# src/meson.build hardcodes CARGO_HOME to ${BUILD_DIR}/cargo-home; point
	# it at the vendored cargo home cargo.eclass already populated so the
	# cargo invocation meson shells out to builds fully offline.
	ln -s "${WORKDIR}"/cargo_home "${BUILD_DIR}"/cargo-home || die
	meson_src_compile
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
