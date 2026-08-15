# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit shell-completion

DESCRIPTION="Dependency manager for PHP"
HOMEPAGE="https://getcomposer.org/ https://github.com/composer/composer"
SRC_URI="https://getcomposer.org/download/${PV}/composer.phar -> ${P}.phar"
S=${WORKDIR}

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

PHP_DEPEND=">=dev-lang/php-7.2.5:*[cli,filter,iconv,json(+),phar,ssl]"

RDEPEND="
	${PHP_DEPEND}
	app-arch/unzip
	dev-vcs/git
"
BDEPEND="${PHP_DEPEND}"

src_unpack() {
	cp "${DISTDIR}/${P}.phar" composer.phar || die
}

src_compile() {
	php composer.phar completion bash > composer.bash || die
}

src_test() {
	local output

	output=$(php composer.phar --no-interaction --version) || die
	[[ ${output} == *"Composer version ${PV} "* ]] ||
		die "Composer reported an unexpected version: ${output}"
}

src_install() {
	newbin composer.phar composer
	newbashcomp composer.bash composer
}
