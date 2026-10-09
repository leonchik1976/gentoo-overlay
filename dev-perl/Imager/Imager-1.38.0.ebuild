# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=TONYC
DIST_VERSION=1.038
inherit perl-module

DESCRIPTION="Image processing library for Perl"

LICENSE="|| ( Artistic GPL-1+ )"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Select the supported image/font drivers explicitly to avoid autodetection.
# These install Imager::File::{GIF,JPEG,PNG,TIFF} and Imager::Font::FT2.
RDEPEND="
	media-libs/freetype:2=
	media-libs/giflib:=
	media-libs/libjpeg-turbo:=
	media-libs/libpng:=
	media-libs/tiff:=
	virtual/perl-Exporter
	virtual/perl-Scalar-List-Utils
	>=virtual/perl-Test-Simple-0.990.0
	virtual/perl-XSLoader
"
DEPEND="${RDEPEND}"
BDEPEND+=" virtual/pkgconfig"

src_configure() {
	export IM_ENABLE="FT2 GIF JPEG PNG TIFF"
	perl-module_src_configure
}
