# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="adler2@2.0.1
	aho-corasick@1.1.4
	aligned-vec@0.6.4
	aligned@0.4.3
	android_system_properties@0.1.5
	annotate-snippets@0.11.5
	anstyle@1.0.14
	anyhow@1.0.102
	arbitrary@1.4.2
	arg_enum_proc_macro@0.3.4
	arrayvec@0.7.6
	as-slice@0.2.1
	async-trait@0.1.89
	atomic@0.6.1
	autocfg@1.5.1
	av-scenechange@0.14.1
	av1-grain@0.2.5
	avif-serialize@0.8.9
	base64@0.22.1
	bigdecimal@0.4.10
	bindgen@0.72.1
	bit_field@0.10.3
	bitflags@2.13.0
	bitstream-io@4.10.0
	bitvec@1.0.1
	block-buffer@0.10.4
	block-buffer@0.12.1
	built@0.8.1
	bumpalo@3.20.3
	bytemuck@1.25.0
	byteorder-lite@0.1.0
	byteorder@1.5.0
	bytes@1.11.1
	c_str_macro@1.0.3
	camino@1.2.2
	cargo-platform@0.1.9
	cargo_metadata@0.18.1
	cargo_toml@0.22.3
	cc@1.2.63
	cee-scape@0.2.0
	cexpr@0.6.0
	cfg-if@1.0.4
	chacha20@0.10.0
	chrono@0.4.45
	clang-sys@1.8.1
	clap-cargo@0.14.1
	clap@4.6.1
	clap_builder@4.6.0
	clap_derive@4.6.1
	clap_lex@1.1.0
	cmov@0.5.4
	codepage@0.1.2
	color_quant@1.1.0
	const-oid@0.10.2
	convert_case@0.11.0
	core-foundation-sys@0.8.7
	cpufeatures@0.3.0
	crc32fast@1.5.0
	crossbeam-deque@0.8.6
	crossbeam-epoch@0.9.18
	crossbeam-utils@0.8.21
	crunchy@0.2.4
	crypto-common@0.1.7
	crypto-common@0.2.2
	ctutils@0.4.2
	deranged@0.5.8
	deunicode@1.6.2
	digest@0.10.7
	digest@0.11.3
	dispatch2@0.3.1
	displaydoc@0.2.6
	either@1.16.0
	encoding_rs@0.8.35
	enum-map-derive@0.17.0
	enum-map@2.7.3
	equator-macro@0.4.2
	equator@0.4.2
	equivalent@1.0.2
	errno@0.3.14
	exr@1.74.0
	eyre@0.6.12
	fake@5.1.0
	fallible-iterator@0.2.0
	fastrand@2.4.1
	fax@0.2.7
	fdeflate@0.3.7
	find-msvc-tools@0.1.9
	fixedbitset@0.5.7
	flate2@1.1.9
	foldhash@0.1.5
	form_urlencoded@1.2.2
	funty@2.0.0
	futures-channel@0.3.32
	futures-core@0.3.32
	futures-sink@0.3.32
	futures-task@0.3.32
	futures-util@0.3.32
	generic-array@0.14.7
	getrandom@0.2.17
	getrandom@0.3.4
	getrandom@0.4.2
	gif@0.14.2
	glob@0.3.3
	half@1.8.3
	half@2.7.1
	hashbrown@0.15.5
	hashbrown@0.17.1
	heck@0.5.0
	hmac@0.13.0
	http@1.4.2
	hybrid-array@0.4.12
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.65
	icu_collections@2.2.0
	icu_locale_core@2.2.0
	icu_normalizer@2.2.0
	icu_normalizer_data@2.2.0
	icu_properties@2.2.0
	icu_properties_data@2.2.0
	icu_provider@2.2.0
	id-arena@2.3.0
	idna@1.1.0
	idna_adapter@1.2.2
	image-webp@0.2.4
	image@0.25.10
	imgref@1.12.2
	indenter@0.3.4
	indexmap@2.14.0
	interpolate_name@0.2.4
	is_ci@1.2.0
	itertools@0.13.0
	itertools@0.14.0
	itoa@1.0.18
	jobserver@0.1.34
	js-sys@0.3.100
	leb128fmt@0.1.0
	lebe@0.5.3
	libc@0.2.186
	libfuzzer-sys@0.4.13
	libloading@0.8.9
	libm@0.2.16
	libredox@0.1.17
	linux-raw-sys@0.12.1
	litemap@0.8.2
	lock_api@0.4.14
	log@0.4.32
	loop9@0.1.5
	maybe-rayon@0.1.1
	md-5@0.10.6
	md-5@0.11.0
	memchr@2.8.1
	minimal-lexical@0.2.1
	miniz_oxide@0.8.9
	mio@1.2.1
	moxcms@0.8.1
	new_debug_unreachable@1.0.6
	no_std_io2@0.9.4
	nom@7.1.3
	nom@8.0.0
	noop_proc_macro@0.3.0
	ntapi@0.4.3
	num-bigint@0.4.6
	num-conv@0.2.2
	num-derive@0.4.2
	num-integer@0.1.46
	num-rational@0.4.2
	num-traits@0.2.19
	objc2-core-foundation@0.3.2
	objc2-encode@4.1.0
	objc2-foundation@0.3.2
	objc2-io-kit@0.3.2
	objc2-open-directory@0.3.2
	objc2-system-configuration@0.3.2
	objc2@0.6.4
	once_cell@1.21.4
	owo-colors@4.3.0
	parking_lot@0.12.5
	parking_lot_core@0.9.12
	paste@1.0.15
	pastey@0.1.1
	pathsearch@0.2.0
	percent-encoding@2.3.2
	petgraph@0.8.3
	pgrx-bindgen@0.18.1
	pgrx-macros@0.18.1
	pgrx-pg-config@0.18.1
	pgrx-pg-sys@0.18.1
	pgrx-sql-entity-graph@0.18.1
	pgrx-tests@0.18.1
	pgrx@0.18.1
	phf@0.13.1
	phf_shared@0.13.1
	pin-project-lite@0.2.17
	png@0.18.1
	postgres-protocol@0.6.12
	postgres-types@0.2.14
	postgres@0.19.13
	potential_utf@0.1.5
	powerfmt@0.2.0
	ppv-lite86@0.2.21
	prettyplease@0.2.37
	proc-macro2@1.0.106
	profiling-procmacros@1.0.18
	profiling@1.0.18
	pxfm@0.1.29
	qoi@0.4.1
	quick-error@2.0.1
	quote@1.0.45
	r-efi@5.3.0
	r-efi@6.0.0
	radium@0.7.0
	rand@0.10.1
	rand@0.8.6
	rand@0.9.4
	rand_chacha@0.3.1
	rand_chacha@0.9.0
	rand_core@0.10.1
	rand_core@0.6.4
	rand_core@0.9.5
	random_color@1.1.0
	rav1e@0.8.1
	ravif@0.13.0
	rayon-core@1.13.0
	rayon@1.12.0
	redox_syscall@0.5.18
	regex-automata@0.4.14
	regex-syntax@0.8.11
	regex@1.12.4
	rgb@0.8.53
	rust_decimal@1.42.0
	rustc-hash@2.1.2
	rustix@1.1.4
	rustversion@1.0.22
	same-file@1.0.6
	scopeguard@1.2.0
	seahash@4.1.0
	semver@1.0.28
	serde@1.0.228
	serde_cbor@0.11.2
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_json@1.0.150
	serde_spanned@1.1.1
	sha1_smol@1.0.1
	sha2@0.11.0
	shlex@1.3.0
	shlex@2.0.1
	simd-adler32@0.3.9
	simd_helpers@0.1.0
	siphasher@1.0.3
	slab@0.4.12
	smallvec@1.15.1
	socket2@0.6.4
	stable_deref_trait@1.2.1
	stringprep@0.1.5
	supports-color@3.0.2
	syn@2.0.117
	synstructure@0.13.2
	sysinfo@0.39.3
	tap@1.0.1
	tempfile@3.27.0
	thiserror-impl@1.0.69
	thiserror-impl@2.0.18
	thiserror@1.0.69
	thiserror@2.0.18
	tiff@0.11.3
	time-core@0.1.8
	time-macros@0.2.27
	time@0.3.47
	tinystr@0.8.3
	tinyvec@1.11.0
	tinyvec_macros@0.1.1
	tokio-postgres@0.7.18
	tokio-util@0.7.18
	tokio@1.52.3
	toml@0.5.11
	toml@0.9.12+spec-1.1.0
	toml_datetime@0.7.5+spec-1.1.0
	toml_parser@1.1.2+spec-1.1.0
	toml_writer@1.1.1+spec-1.1.0
	typenum@1.20.1
	unescape@0.1.0
	unicode-bidi@0.3.18
	unicode-ident@1.0.24
	unicode-normalization@0.1.25
	unicode-properties@0.1.4
	unicode-segmentation@1.13.3
	unicode-width@0.2.2
	unicode-xid@0.2.6
	url-escape@0.1.1
	url@2.5.8
	utf8_iter@1.0.4
	uuid@1.23.3
	v_frame@0.3.9
	version_check@0.9.5
	walkdir@2.5.0
	wasi@0.11.1+wasi-snapshot-preview1
	wasi@0.14.7+wasi-0.2.4
	wasip2@1.0.3+wasi-0.2.9
	wasip3@0.4.0+wasi-0.3.0-rc-2026-01-06
	wasite@1.0.2
	wasm-bindgen-macro-support@0.2.123
	wasm-bindgen-macro@0.2.123
	wasm-bindgen-shared@0.2.123
	wasm-bindgen@0.2.123
	wasm-encoder@0.244.0
	wasm-metadata@0.244.0
	wasmparser@0.244.0
	web-sys@0.3.100
	weezl@0.1.12
	whoami@2.1.2
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.11
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-collections@0.3.2
	windows-core@0.62.2
	windows-future@0.3.2
	windows-implement@0.60.2
	windows-interface@0.59.3
	windows-link@0.2.1
	windows-numerics@0.3.1
	windows-result@0.4.1
	windows-strings@0.5.1
	windows-sys@0.61.2
	windows-threading@0.2.1
	windows@0.62.2
	winnow@0.7.15
	winnow@1.0.3
	wit-bindgen-core@0.51.0
	wit-bindgen-rust-macro@0.51.0
	wit-bindgen-rust@0.51.0
	wit-bindgen@0.51.0
	wit-bindgen@0.57.1
	wit-component@0.244.0
	wit-parser@0.244.0
	writeable@0.6.3
	wyz@0.5.1
	y4m@0.8.0
	yoke-derive@0.8.2
	yoke@0.8.3
	zerocopy-derive@0.8.52
	zerocopy@0.8.52
	zerofrom-derive@0.1.7
	zerofrom@0.1.8
	zerotrie@0.2.4
	zerovec-derive@0.11.3
	zerovec@0.11.6
	zmij@1.0.21
	zune-core@0.5.1
	zune-inflate@0.2.54
	zune-jpeg@0.5.15"
RUST_MIN_VER="1.96.0"
RUST_REQ_USE="rustfmt"
LLVM_COMPAT=( {16..22} )
POSTGRES_COMPAT=( {14..18} )
POSTGRES_USEDEP="server"

inherit cargo edo llvm-r2 postgres

DESCRIPTION="Anonymization & Data Masking for PostgreSQL"
HOMEPAGE="https://gitlab.com/dalibo/postgresql_anonymizer"
SRC_URI="https://gitlab.com/dalibo/${PN}/-/archive/${PV}/${P}.tar.bz2
	${CARGO_CRATE_URIS}"

# POSTGRESQL covers the extension's own PL/pgSQL and C code. The rest is
# the audited union of every crates.io dependency's license field in
# Cargo.lock at this exact tag (352 packages, verified individually via
# the crates.io API, not carried over from an older CRATES list): a
# dependency's license is only counted here if it has no MIT/Apache-2.0
# alternative to fall back to, e.g. plain "BSD-2-Clause" (av1-grain,
# rav1e, v_frame), "(MIT OR Apache-2.0) AND NCSA" (libfuzzer-sys), or
# "Unicode-3.0" (several icu_* crates; this crate set no longer uses the
# older Unicode-DFS-2016 SPDX id at all, so that entry was dropped, and
# plain "Zlib" (foldhash) is likewise mandatory, not merely an
# MIT/Apache-2.0-satisfiable alternative as it is for most other crates
# offering it. Permissive OR-alternatives that are always satisfiable via
# the MIT or Apache-2.0 branch already present (0BSD, BSL-1.0, CC0-1.0,
# LGPL-2.1-or-later, Unlicense) are intentionally not listed.
LICENSE="Apache-2.0 BSD BSD-2 ISC MIT POSTGRESQL UoI-NCSA Unicode-3.0 ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="${POSTGRES_REQ_USE} ${LLVM_REQUIRED_USE}"
RESTRICT="test" # installs extension outside of sandbox

RDEPEND="${POSTGRES_DEP}"
BDEPEND="=dev-util/cargo-pgrx-0.18.1*
	virtual/pkgconfig
	$(llvm_gen_dep 'llvm-core/clang:${LLVM_SLOT}')"

DOCS=( {CHANGELOG,NEWS,README}.md )

QA_FLAGS_IGNORED="usr/lib.*/postgresql-.*/lib.*/anon.so"

pkg_setup() {
	llvm-r2_pkg_setup
	postgres_pkg_setup
	rust_pkg_setup
}

src_prepare() {
	default

	export PGRX_HOME="${WORKDIR}/${P}"/.pgrx
	edo cargo pgrx init --pg"${PG_SLOT}" "${PG_CONFIG}"
}

src_compile() {
	emake extension PGVER=pg"${PG_SLOT}"
}

src_test() {
	emake test PGVER=pg"${PG_SLOT}"
}

src_install() {
	einstalldocs

	local PG_PKGLIBDIR PG_SHAREDIR
	PG_PKGLIBDIR="$($PG_CONFIG --libdir)"
	PG_SHAREDIR="$($PG_CONFIG --sharedir)"

	dodir "${PG_SHAREDIR}"/extension "${PG_PKGLIBDIR}"
	emake install PGVER=pg"${PG_SLOT}" \
		PG_SHAREDIR="${ED}/${PG_SHAREDIR}" \
		TARGET_SHAREDIR="target/release/anon-pg${PG_SLOT}/${PG_SHAREDIR}" \
		PG_PKGLIBDIR="${ED}/${PG_PKGLIBDIR}" \
		TARGET_PKGLIBDIR="target/release/anon-pg${PG_SLOT}/${PG_PKGLIBDIR}"
}
