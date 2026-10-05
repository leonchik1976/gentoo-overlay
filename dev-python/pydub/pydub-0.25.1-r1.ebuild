# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 optfeature

DESCRIPTION="Manipulate audio with a simple high level interface"
HOMEPAGE="http://pydub.com/"
SRC_URI="https://github.com/jiaaro/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="${RDEPEND}
	$(python_gen_cond_dep '
		dev-python/audioop-lts[${PYTHON_USEDEP}]
	' python3_13 python3_14)
"

BDEPEND="${BDEPEND}
	>=dev-python/setuptools-77[${PYTHON_USEDEP}]
	test? (
		media-video/ffmpeg[lame,vorbis]
	)
"

PATCHES=(
	"${FILESDIR}/${P}-license-metadata.patch"
	"${FILESDIR}/${P}-wheel-config.patch"
)

distutils_enable_tests unittest

python_test() {
	eunittest test/
}

pkg_postinst() {
	optfeature "opening and saving non-wav files - like mp3" media-video/ffmpeg
	#optfeature "playing audio" dev-python/simpleaudio # upstream suggests this, not available in gentoo or guru
	optfeature "playing audio" dev-python/pyaudio
}
