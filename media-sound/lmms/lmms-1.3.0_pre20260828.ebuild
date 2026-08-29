# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg

MY_COMMIT="dff0fbd67feb18c291640e9a6640305b6a514d59"

# Submodule commit pins actually required to build with this ebuild's
# WANT_* cmake configuration below (verified against .gitmodules and
# CMakeLists.txt at ${MY_COMMIT}, not assumed). Intentionally omitted:
# calf/veal, swh/ladspa, tap-plugins, cmt (gated on WANT_CALF/WANT_SWH/
# WANT_TAP/WANT_CMT, hardcoded OFF below), zynaddsubfx (plugin excluded
# entirely via PLUGIN_LIST below -- see the LICENSE= comment), doc/wiki
# (wiki content), and qt5-x11embed (only used for a Qt5+VST build;
# WANT_QT6 is always ON here).
#
# unconditional: GME, ADPLUG, EXPRTK, PORTSMF, HIIR, RINGBUFFER
# USE=carla:     CARLA (weak-linking header fallback)
# USE=sid:       RESID
# USE=jack:      WEAKJACK, JACK2 (WANT_WEAKJACK defaults ON)
GME_COMMIT="21a064ea66a5cdf71910e207c4756095c266814f"
ADPLUG_COMMIT="3ed6617ec00022dfab574c27710d9071a6032c87"
EXPRTK_COMMIT="a4b17d543f072d2e3ba564e4bc5c3a0d2b05c338"
PORTSMF_COMMIT="081261bcfd8faca4cee8560010de34831c0dea97"
HIIR_COMMIT="4a9a1e67fa6f8ce7688e1c0c8a2b017cecd206a3"
RINGBUFFER_COMMIT="1c46ef34a28d4637b43fb6d5ebb31d38c05f4bd8"
CARLA_COMMIT="66afe24a08790732cc17d81d4b846a1e0cfa0118"
RESID_COMMIT="ef72462f5fa0682d099413512b764ae479e77f9b"
WEAKJACK_COMMIT="fd11655be3b2efd6082968ecfe53f9cfe88bda2b"
JACK2_COMMIT="ac334fabfb56989e9115ee6e2a77c1f6162d14fb"

DESCRIPTION="Cross-platform music production software"
HOMEPAGE="https://lmms.io https://github.com/LMMS/lmms"
SRC_URI="
	https://github.com/LMMS/lmms/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz
	https://github.com/libgme/game-music-emu/archive/${GME_COMMIT}.tar.gz -> ${P}-game-music-emu-${GME_COMMIT}.tar.gz
	https://github.com/adplug/adplug/archive/${ADPLUG_COMMIT}.tar.gz -> ${P}-adplug-${ADPLUG_COMMIT}.tar.gz
	https://github.com/ArashPartow/exprtk/archive/${EXPRTK_COMMIT}.tar.gz -> ${P}-exprtk-${EXPRTK_COMMIT}.tar.gz
	https://github.com/portsmf/portsmf/archive/${PORTSMF_COMMIT}.tar.gz -> ${P}-portsmf-${PORTSMF_COMMIT}.tar.gz
	https://github.com/LostRobotMusic/hiir/archive/${HIIR_COMMIT}.tar.gz -> ${P}-hiir-${HIIR_COMMIT}.tar.gz
	https://github.com/JohannesLorenz/ringbuffer/archive/${RINGBUFFER_COMMIT}.tar.gz
		-> ${P}-ringbuffer-${RINGBUFFER_COMMIT}.tar.gz
	carla? ( https://github.com/falktx/carla/archive/${CARLA_COMMIT}.tar.gz -> ${P}-carla-${CARLA_COMMIT}.tar.gz )
	sid? ( https://github.com/libsidplayfp/resid/archive/${RESID_COMMIT}.tar.gz -> ${P}-resid-${RESID_COMMIT}.tar.gz )
	jack? (
		https://github.com/x42/weakjack/archive/${WEAKJACK_COMMIT}.tar.gz -> ${P}-weakjack-${WEAKJACK_COMMIT}.tar.gz
		https://github.com/jackaudio/jack2/archive/${JACK2_COMMIT}.tar.gz -> ${P}-jack2-${JACK2_COMMIT}.tar.gz
	)
"
S="${WORKDIR}/lmms-${MY_COMMIT}"

# Full bundled-source license/compatibility audit is documented in detail
# in docs/lmms-license-audit.md at the repo root (kept out of the ebuild
# body since it's long). Summary: LMMS core + carla/resid/weakjack headers are
# GPL-2+; game-music-emu is LGPL-2.1; adplug is LGPL-2.1+; exprtk is MIT;
# hiir is WTFPL; ringbuffer is GPL-3+ (statically linked into lmmsobjs,
# which every plugin links against via BUILD_PLUGIN's
# target_link_libraries(<plugin> lmms ...) -- unproblematic for LMMS's own
# GPL-2+ plugins, but a real GPL-2-only/GPL-3+ combination conflict for the
# ZynAddSubFx plugin specifically, since its own upstream COPYING is plain
# GPL-2 with no "or later" grant. Resolved by excluding ZynAddSubFx from
# the build entirely (PLUGIN_LIST override below) rather than treating the
# conflict as acceptable -- see the audit doc for the full evidence trail.
LICENSE="GPL-2+ LGPL-2.1 LGPL-2.1+ MIT WTFPL GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
# media-libs/libgig and media-libs/stk both lack any arm64 keyword in
# ::gentoo as of 2026-08-21 (neither has even a ~arm64 entry). USE=gig and
# USE=stk have been build-tested successfully on arm64 by this ebuild
# (confirmed with a real build+install, see docs/lmms-validation-log.md),
# but a user enabling either on arm64 currently needs to accept those two
# packages' missing keywords themselves (e.g. via package.accept_keywords),
# same as for any other dependency ::gentoo hasn't keyworded yet on a
# given arch. That's a normal Portage workflow, not a defect in this
# ebuild.
IUSE="alsa carla fluidsynth gig jack lv2 mp3 ogg portaudio pulseaudio sdl sid sndio soundio stk test vst"
RESTRICT="!test? ( test )"

# Upstream no longer publishes stable release tarballs that build with
# current CMake (see bugs.gentoo.org/957460, the reason lmms-1.2.2 was
# treecleaned from ::gentoo); this snapshot pins a known-good commit from
# the unreleased 1.3.0 development branch instead of tracking live git.
# See the *_COMMIT variables above for the (also pinned, also
# Manifest-checksummed) submodule contents this build actually needs.
COMMON_DEPEND="
	>=media-libs/libsamplerate-0.1.8
	>=media-libs/libsndfile-1.0.11
	>=x11-libs/fltk-1.3.0_rc3:1
	dev-qt/qtbase:6[gui,widgets,xml]
	dev-qt/qtsvg:6
	sci-libs/fftw:3.0
	alsa? ( media-libs/alsa-lib )
	carla? ( media-sound/carla )
	fluidsynth? ( >=media-sound/fluidsynth-1.1.7:= )
	gig? ( media-libs/libgig )
	jack? ( virtual/jack )
	lv2? (
		media-libs/lilv
		media-libs/suil
	)
	mp3? ( media-sound/lame )
	ogg? (
		media-libs/libogg
		media-libs/libvorbis
	)
	portaudio? ( >=media-libs/portaudio-19_pre )
	pulseaudio? ( media-libs/libpulse )
	sdl? (
		media-libs/libsdl
		>=media-libs/sdl-sound-1.0.1
	)
	sndio? ( media-sound/sndio )
	soundio? ( media-libs/libsoundio )
	stk? ( media-libs/stk )
	vst? ( virtual/wine )
"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"
BDEPEND="dev-qt/qttools:6[linguist]"

DOCS=( README.md )

PATCHES=(
	"${FILESDIR}/${PN}-1.3.0-cmake-minimums.patch"
)

_place_submodule() {
	local extracted=$1 dest=$2
	rm -rf "${S}/${dest}" || die
	mv "${WORKDIR}/${extracted}" "${S}/${dest}" || die
}

# Submodules this build doesn't need content for -- either never (see the
# *_COMMIT comment block above) or because the relevant USE flag is off
# this run -- are left as the empty directories the main tarball ships.
# cmake/modules/CheckSubmodules.cmake doesn't know that: it walks every
# path in .gitmodules and shells out to `git submodule update` for any of
# them lacking a "crumb" file (CMakeLists.txt, .gitignore, etc), which
# fails outright since this is a plain tarball checkout, not a git working
# tree. Its own skip mechanism (PLUGIN_LIST) only covers plugins/-prefixed
# paths, defaults to including every plugin regardless of our WANT_* USE
# mapping, and doesn't cover src/3rdparty/ paths at all -- so it can't be
# relied on here either way. Dropping a trivial .gitignore into each
# unpopulated path satisfies that pre-configure check without fetching
# content no ADD_SUBDIRECTORY()/CMakeLists.txt in this configuration
# ever touches.
_stub_unused_submodule() {
	echo "*" > "${S}/${1}/.gitignore" || die
}

src_prepare() {
	cmake_src_prepare

	_stub_unused_submodule "src/3rdparty/qt5-x11embed"
	_stub_unused_submodule "plugins/LadspaEffect/calf/veal"
	_stub_unused_submodule "plugins/LadspaEffect/swh/ladspa"
	_stub_unused_submodule "plugins/LadspaEffect/tap/tap-plugins"
	_stub_unused_submodule "plugins/LadspaEffect/cmt/cmt"
	_stub_unused_submodule "plugins/ZynAddSubFx/zynaddsubfx"
	_stub_unused_submodule "doc/wiki"

	use carla || _stub_unused_submodule "plugins/CarlaBase/carla"
	use sid || _stub_unused_submodule "plugins/Sid/resid/resid"
	if ! use jack; then
		_stub_unused_submodule "src/3rdparty/weakjack/weakjack"
		_stub_unused_submodule "src/3rdparty/jack2"
	fi
}

src_unpack() {
	default

	_place_submodule "game-music-emu-${GME_COMMIT}" "plugins/FreeBoy/game-music-emu"
	_place_submodule "adplug-${ADPLUG_COMMIT}" "plugins/OpulenZ/adplug"
	_place_submodule "exprtk-${EXPRTK_COMMIT}" "plugins/Xpressive/exprtk"
	_place_submodule "portsmf-${PORTSMF_COMMIT}" "plugins/MidiImport/portsmf"
	_place_submodule "hiir-${HIIR_COMMIT}" "src/3rdparty/hiir/hiir"
	_place_submodule "ringbuffer-${RINGBUFFER_COMMIT}" "src/3rdparty/ringbuffer"

	use carla && _place_submodule "Carla-${CARLA_COMMIT}" "plugins/CarlaBase/carla"
	use sid && _place_submodule "resid-${RESID_COMMIT}" "plugins/Sid/resid/resid"
	if use jack; then
		_place_submodule "weakjack-${WEAKJACK_COMMIT}" "src/3rdparty/weakjack/weakjack"
		_place_submodule "jack2-${JACK2_COMMIT}" "src/3rdparty/jack2"
	fi
}

src_configure() {
	local mycmakeargs=(
		-DUSE_WERROR=OFF
		-DWANT_QT6=ON
		# Exclude the ZynAddSubFx plugin entirely (full LMMS_PLUGIN_LIST from
		# cmake/modules/PluginList.cmake, minus ZynAddSubFx): its own
		# upstream COPYING is plain GPL-2 (no "or later"), and every plugin
		# links against the "lmms" executable target via BUILD_PLUGIN's
		# target_link_libraries(<plugin> lmms ...), which contains the
		# GPL-3+ vendored ringbuffer (real compiled code, not header-only) --
		# a genuine GPL-2-only/GPL-3+ combination conflict. See
		# docs/lmms-license-audit.md for the full evidence trail.
		"-DPLUGIN_LIST=AudioFileProcessor;Kicker;TripleOscillator;Amplifier;BassBooster;BitInvader;Bitcrush;CarlaBase;CarlaPatchbay;CarlaRack;Compressor;CrossoverEQ;Delay;Dispersion;DualFilter;DynamicsProcessor;Eq;Flanger;FrequencyShifter;GranularPitchShifter;HydrogenImport;LadspaBrowser;LadspaEffect;LOMM;Lv2Effect;Lv2Instrument;Lb302;MidiImport;MidiExport;MultitapEcho;Monstro;Nes;OpulenZ;Organic;Oscilloscope;FreeBoy;Patman;PeakControllerEffect;GigPlayer;ReverbSC;Sf2Player;Sfxr;Sid;SlewDistortion;SlicerT;SpectrumAnalyzer;StereoEnhancer;StereoMatrix;Stk;TapTempo;VstBase;Vestige;VstEffect;Watsyn;WaveShaper;Vectorscope;Vibed;Xpressive"
		# Always prefer the separately packaged system LADSPA plugin sets
		# over these bundled copies; LMMS loads LADSPA plugins from the
		# system search path at runtime regardless of this setting.
		-DWANT_CALF=OFF
		-DWANT_CAPS=OFF
		-DWANT_CMT=OFF
		-DWANT_SWH=OFF
		-DWANT_TAP=OFF
		-DWANT_ALSA=$(usex alsa)
		-DWANT_CARLA=$(usex carla)
		-DWANT_SF2=$(usex fluidsynth)
		-DWANT_GIG=$(usex gig)
		-DWANT_JACK=$(usex jack)
		-DWANT_LV2=$(usex lv2)
		-DWANT_SUIL=$(usex lv2)
		-DWANT_MP3LAME=$(usex mp3)
		-DWANT_OGGVORBIS=$(usex ogg)
		-DWANT_PORTAUDIO=$(usex portaudio)
		-DWANT_PULSEAUDIO=$(usex pulseaudio)
		-DWANT_SDL=$(usex sdl)
		-DWANT_SID=$(usex sid)
		-DWANT_SNDIO=$(usex sndio)
		-DWANT_SOUNDIO=$(usex soundio)
		-DWANT_STK=$(usex stk)
		-DWANT_VST=$(usex vst)
		-DWANT_VST_32=OFF
		-DWANT_VST_64=$(usex vst)
	)

	cmake_src_configure
}

src_install() {
	# Upstream's own CMake install rule pre-compresses the man page as
	# .bz2; leave it alone rather than let Portage's docompress try to
	# re-handle an already-compressed file in a format it doesn't expect.
	docompress -x /usr/share/man
	cmake_src_install

	# Orphaned preset data for the excluded ZynAddSubFx plugin (see
	# src_configure PLUGIN_LIST comment) -- not code, no licensing issue,
	# just dead weight for a plugin this build doesn't ship.
	rm -r "${ED}/usr/share/lmms/presets/ZynAddSubFX" || die
}
