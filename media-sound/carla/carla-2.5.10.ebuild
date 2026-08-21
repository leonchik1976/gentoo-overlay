# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="Carla"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Audio plugin host engine and LV2/VST bridges, supporting many plugin formats"
HOMEPAGE="https://kx.studio/Applications:Carla https://github.com/falkTX/Carla"
SRC_URI="https://github.com/falkTX/Carla/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${MY_P}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+alsa fluidsynth +jack osc +pulseaudio sdl +sndfile X"

# NOTE: Carla's standalone Qt/Python GUI (the "carla", "carla-rack",
# "carla-patchbay" launchers) requires dev-python/pyqt5, which no longer
# exists in ::gentoo or any overlay configured on this system (treeclean'd
# upstream in Gentoo, see profiles history for dev-python/pyqt5). This
# ebuild therefore builds only the audio engine, discovery tool and
# LV2/plugin bridges (HAVE_PYQT auto-detects to false since pyuic5/pyrcc5
# are unavailable); Carla remains usable headless or as an LV2 plugin
# inside another host.
RDEPEND="
	sys-apps/file
	alsa? ( media-libs/alsa-lib )
	fluidsynth? ( media-sound/fluidsynth )
	jack? ( virtual/jack )
	osc? ( media-libs/liblo )
	pulseaudio? ( media-libs/libpulse )
	sdl? ( media-libs/libsdl2 )
	sndfile? ( media-libs/libsndfile )
	X? ( x11-libs/libX11 )
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/${P}-fix-eel2-strict-aliasing.patch"
)

carla_emake_args() {
	myemakeargs=(
		PREFIX="/usr"
		LIBDIR="/usr/$(get_libdir)"
		SKIP_STRIPPING=true
		HAVE_FFMPEG=false
		HAVE_ZYN_DEPS=false
		HAVE_ZYN_UI_DEPS=false
		HAVE_QT4=false
		HAVE_QT5=false
		HAVE_QT5PKG=false
		HAVE_QT6=false
		HAVE_GTK2=false
		HAVE_GTK3=false
		HAVE_ALSA=$(usex alsa true false)
		HAVE_FLUIDSYNTH=$(usex fluidsynth true false)
		HAVE_JACK=$(usex jack true false)
		HAVE_JACKLIB=$(usex jack true false)
		HAVE_LIBLO=$(usex osc true false)
		HAVE_PULSEAUDIO=$(usex pulseaudio true false)
		HAVE_SDL2=$(usex sdl true false)
		HAVE_SNDFILE=$(usex sndfile true false)
		HAVE_X11=$(usex X true false)
	)
}

src_compile() {
	local myemakeargs
	carla_emake_args

	# print detected feature set for the build log
	emake "${myemakeargs[@]}" features

	emake "${myemakeargs[@]}"
}

src_install() {
	local myemakeargs
	carla_emake_args

	emake DESTDIR="${D}" "${myemakeargs[@]}" install

	# carla-single requires resources installed only when HAVE_PYQT=true.
	rm -v "${ED}/usr/bin/carla-single" || die
}
