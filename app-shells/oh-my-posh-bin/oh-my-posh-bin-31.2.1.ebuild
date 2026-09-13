# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="Prompt theme engine for any shell, packaged from upstream prebuilt binaries"
HOMEPAGE="https://ohmyposh.dev/ https://github.com/JanDeDobbeleer/oh-my-posh"
SRC_URI="
	amd64? ( https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${PV}/posh-linux-amd64 -> ${P}-linux-amd64 )
	arm64? ( https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${PV}/posh-linux-arm64 -> ${P}-linux-arm64 )
	https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${PV}/themes.zip -> ${P}-themes.zip
"
GO_MODULE_LICENSES=(
	"oh-my-posh-bin-31.2.1-module-dario.cat-mergo-v1.0.2.zip|dario.cat/mergo@v1.0.2/LICENSE"
	"oh-my-posh-bin-31.2.1-module-github.com-Masterminds-goutils-v1.1.1.zip|github.com/Masterminds/goutils@v1.1.1/LICENSE.txt"
	"oh-my-posh-bin-31.2.1-module-github.com-Masterminds-semver-v3-v3.4.0.zip|github.com/Masterminds/semver/v3@v3.4.0/LICENSE.txt"
	"oh-my-posh-bin-31.2.1-module-github.com-Masterminds-sprig-v3-v3.3.0.zip|github.com/Masterminds/sprig/v3@v3.3.0/LICENSE.txt"
	"oh-my-posh-bin-31.2.1-module-github.com-go-git-gcfg-v1.5.1-0.20230307220236-3a3c6141e376.zip|github.com/go-git/gcfg@v1.5.1-0.20230307220236-3a3c6141e376/LICENSE"
	"oh-my-posh-bin-31.2.1-module-github.com-go-git-go-billy-v5-v5.9.0.zip|github.com/go-git/go-billy/v5@v5.9.0/LICENSE"
	"oh-my-posh-bin-31.2.1-module-github.com-go-git-go-git-v5-v5.19.2.zip|github.com/go-git/go-git/v5@v5.19.2/LICENSE"
	"oh-my-posh-bin-31.2.1-module-github.com-google-uuid-v1.6.0.zip|github.com/google/uuid@v1.6.0/LICENSE"
	"oh-my-posh-bin-31.2.1-module-github.com-gookit-color-v1.6.1.zip|github.com/gookit/color@v1.6.1/LICENSE"
	"oh-my-posh-bin-31.2.1-module-github.com-huandu-xstrings-v1.5.0.zip|github.com/huandu/xstrings@v1.5.0/LICENSE"
	"oh-my-posh-bin-31.2.1-module-github.com-jbenet-go-context-v0.0.0-20150711004518-d14ea06fba99.zip|github.com/jbenet/go-context@v0.0.0-20150711004518-d14ea06fba99/LICENSE"
	"oh-my-posh-bin-31.2.1-module-github.com-klauspost-cpuid-v2-v2.3.0.zip|github.com/klauspost/cpuid/v2@v2.3.0/LICENSE"
	"oh-my-posh-bin-31.2.1-module-github.com-lucasb-eyer-go-colorful-v1.4.1.zip|github.com/lucasb-eyer/go-colorful@v1.4.1/LICENSE"
	"oh-my-posh-bin-31.2.1-module-github.com-mitchellh-copystructure-v1.2.0.zip|github.com/mitchellh/copystructure@v1.2.0/LICENSE"
	"oh-my-posh-bin-31.2.1-module-github.com-mitchellh-reflectwalk-v1.0.2.zip|github.com/mitchellh/reflectwalk@v1.0.2/LICENSE"
	"oh-my-posh-bin-31.2.1-module-github.com-pelletier-go-toml-v2-v2.4.3.zip|github.com/pelletier/go-toml/v2@v2.4.3/LICENSE"
	"oh-my-posh-bin-31.2.1-module-github.com-pjbgf-sha1cd-v0.6.0.zip|github.com/pjbgf/sha1cd@v0.6.0/LICENSE"
	"oh-my-posh-bin-31.2.1-module-github.com-shirou-gopsutil-v4-v4.26.8.zip|github.com/shirou/gopsutil/v4@v4.26.8/LICENSE"
	"oh-my-posh-bin-31.2.1-module-github.com-shopspring-decimal-v1.4.0.zip|github.com/shopspring/decimal@v1.4.0/LICENSE"
	"oh-my-posh-bin-31.2.1-module-github.com-spf13-cast-v1.10.0.zip|github.com/spf13/cast@v1.10.0/LICENSE"
	"oh-my-posh-bin-31.2.1-module-github.com-tklauser-go-sysconf-v0.3.16.zip|github.com/tklauser/go-sysconf@v0.3.16/LICENSE"
	"oh-my-posh-bin-31.2.1-module-github.com-tklauser-numcpus-v0.11.0.zip|github.com/tklauser/numcpus@v0.11.0/LICENSE"
	"oh-my-posh-bin-31.2.1-module-github.com-wayneashleyberry-terminal-dimensions-v1.1.0.zip|github.com/wayneashleyberry/terminal-dimensions@v1.1.0/license"
	"oh-my-posh-bin-31.2.1-module-github.com-xo-terminfo-v0.0.0-20220910002029-abceb7e1c41e.zip|github.com/xo/terminfo@v0.0.0-20220910002029-abceb7e1c41e/LICENSE"
	"oh-my-posh-bin-31.2.1-module-go.yaml.in-yaml-v3-v3.0.5.zip|go.yaml.in/yaml/v3@v3.0.5/LICENSE"
	"oh-my-posh-bin-31.2.1-module-go.yaml.in-yaml-v3-v3.0.5.zip|go.yaml.in/yaml/v3@v3.0.5/LICENSE"
	"oh-my-posh-bin-31.2.1-module-golang.org-x-crypto-v0.53.0.zip|golang.org/x/crypto@v0.53.0/LICENSE"
	"oh-my-posh-bin-31.2.1-module-golang.org-x-net-v0.56.0.zip|golang.org/x/net@v0.56.0/LICENSE"
	"oh-my-posh-bin-31.2.1-module-golang.org-x-sys-v0.47.0.zip|golang.org/x/sys@v0.47.0/LICENSE"
	"oh-my-posh-bin-31.2.1-module-golang.org-x-text-v0.41.0.zip|golang.org/x/text@v0.41.0/LICENSE"
	"oh-my-posh-bin-31.2.1-module-gopkg.in-warnings.v0-v0.1.2.zip|gopkg.in/warnings.v0@v0.1.2/LICENSE"
)
SRC_URI+="
	https://proxy.golang.org/dario.cat/mergo/@v/v1.0.2.zip -> oh-my-posh-bin-31.2.1-module-dario.cat-mergo-v1.0.2.zip
	https://proxy.golang.org/github.com/!masterminds/goutils/@v/v1.1.1.zip -> oh-my-posh-bin-31.2.1-module-github.com-Masterminds-goutils-v1.1.1.zip
	https://proxy.golang.org/github.com/!masterminds/semver/v3/@v/v3.4.0.zip -> oh-my-posh-bin-31.2.1-module-github.com-Masterminds-semver-v3-v3.4.0.zip
	https://proxy.golang.org/github.com/!masterminds/sprig/v3/@v/v3.3.0.zip -> oh-my-posh-bin-31.2.1-module-github.com-Masterminds-sprig-v3-v3.3.0.zip
	https://proxy.golang.org/github.com/go-git/gcfg/@v/v1.5.1-0.20230307220236-3a3c6141e376.zip -> oh-my-posh-bin-31.2.1-module-github.com-go-git-gcfg-v1.5.1-0.20230307220236-3a3c6141e376.zip
	https://proxy.golang.org/github.com/go-git/go-billy/v5/@v/v5.9.0.zip -> oh-my-posh-bin-31.2.1-module-github.com-go-git-go-billy-v5-v5.9.0.zip
	https://proxy.golang.org/github.com/go-git/go-git/v5/@v/v5.19.2.zip -> oh-my-posh-bin-31.2.1-module-github.com-go-git-go-git-v5-v5.19.2.zip
	https://proxy.golang.org/github.com/google/uuid/@v/v1.6.0.zip -> oh-my-posh-bin-31.2.1-module-github.com-google-uuid-v1.6.0.zip
	https://proxy.golang.org/github.com/gookit/color/@v/v1.6.1.zip -> oh-my-posh-bin-31.2.1-module-github.com-gookit-color-v1.6.1.zip
	https://proxy.golang.org/github.com/huandu/xstrings/@v/v1.5.0.zip -> oh-my-posh-bin-31.2.1-module-github.com-huandu-xstrings-v1.5.0.zip
	https://proxy.golang.org/github.com/jbenet/go-context/@v/v0.0.0-20150711004518-d14ea06fba99.zip -> oh-my-posh-bin-31.2.1-module-github.com-jbenet-go-context-v0.0.0-20150711004518-d14ea06fba99.zip
	https://proxy.golang.org/github.com/klauspost/cpuid/v2/@v/v2.3.0.zip -> oh-my-posh-bin-31.2.1-module-github.com-klauspost-cpuid-v2-v2.3.0.zip
	https://proxy.golang.org/github.com/lucasb-eyer/go-colorful/@v/v1.4.1.zip -> oh-my-posh-bin-31.2.1-module-github.com-lucasb-eyer-go-colorful-v1.4.1.zip
	https://proxy.golang.org/github.com/mitchellh/copystructure/@v/v1.2.0.zip -> oh-my-posh-bin-31.2.1-module-github.com-mitchellh-copystructure-v1.2.0.zip
	https://proxy.golang.org/github.com/mitchellh/reflectwalk/@v/v1.0.2.zip -> oh-my-posh-bin-31.2.1-module-github.com-mitchellh-reflectwalk-v1.0.2.zip
	https://proxy.golang.org/github.com/pelletier/go-toml/v2/@v/v2.4.3.zip -> oh-my-posh-bin-31.2.1-module-github.com-pelletier-go-toml-v2-v2.4.3.zip
	https://proxy.golang.org/github.com/pjbgf/sha1cd/@v/v0.6.0.zip -> oh-my-posh-bin-31.2.1-module-github.com-pjbgf-sha1cd-v0.6.0.zip
	https://proxy.golang.org/github.com/shirou/gopsutil/v4/@v/v4.26.8.zip -> oh-my-posh-bin-31.2.1-module-github.com-shirou-gopsutil-v4-v4.26.8.zip
	https://proxy.golang.org/github.com/shopspring/decimal/@v/v1.4.0.zip -> oh-my-posh-bin-31.2.1-module-github.com-shopspring-decimal-v1.4.0.zip
	https://proxy.golang.org/github.com/spf13/cast/@v/v1.10.0.zip -> oh-my-posh-bin-31.2.1-module-github.com-spf13-cast-v1.10.0.zip
	https://proxy.golang.org/github.com/tklauser/go-sysconf/@v/v0.3.16.zip -> oh-my-posh-bin-31.2.1-module-github.com-tklauser-go-sysconf-v0.3.16.zip
	https://proxy.golang.org/github.com/tklauser/numcpus/@v/v0.11.0.zip -> oh-my-posh-bin-31.2.1-module-github.com-tklauser-numcpus-v0.11.0.zip
	https://proxy.golang.org/github.com/wayneashleyberry/terminal-dimensions/@v/v1.1.0.zip -> oh-my-posh-bin-31.2.1-module-github.com-wayneashleyberry-terminal-dimensions-v1.1.0.zip
	https://proxy.golang.org/github.com/xo/terminfo/@v/v0.0.0-20220910002029-abceb7e1c41e.zip -> oh-my-posh-bin-31.2.1-module-github.com-xo-terminfo-v0.0.0-20220910002029-abceb7e1c41e.zip
	https://proxy.golang.org/go.yaml.in/yaml/v3/@v/v3.0.5.zip -> oh-my-posh-bin-31.2.1-module-go.yaml.in-yaml-v3-v3.0.5.zip
	https://proxy.golang.org/golang.org/x/crypto/@v/v0.53.0.zip -> oh-my-posh-bin-31.2.1-module-golang.org-x-crypto-v0.53.0.zip
	https://proxy.golang.org/golang.org/x/net/@v/v0.56.0.zip -> oh-my-posh-bin-31.2.1-module-golang.org-x-net-v0.56.0.zip
	https://proxy.golang.org/golang.org/x/sys/@v/v0.47.0.zip -> oh-my-posh-bin-31.2.1-module-golang.org-x-sys-v0.47.0.zip
	https://proxy.golang.org/golang.org/x/text/@v/v0.41.0.zip -> oh-my-posh-bin-31.2.1-module-golang.org-x-text-v0.41.0.zip
	https://proxy.golang.org/gopkg.in/warnings.v0/@v/v0.1.2.zip -> oh-my-posh-bin-31.2.1-module-gopkg.in-warnings.v0-v0.1.2.zip
"

S="${WORKDIR}"

# MIT project; exact release binary contains 30 Go dependency modules.
# Their upstream license texts were inspected with lichen and are included
# in files/NOTICE.deps-31.2.1.txt. BSD-3-Clause maps to Gentoo BSD.
# go.yaml.in/yaml/v3 includes both MIT and Apache-2.0 source files.
LICENSE="MIT Apache-2.0 BSD BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="app-arch/unzip"

QA_PREBUILT="usr/bin/oh-my-posh"

src_unpack() {
	# The arch binary is a bare ELF with no recognized archive extension;
	# default src_unpack's `unpack` helper does not copy such files into
	# ${WORKDIR} at all, so pull it from ${DISTDIR} explicitly. Only
	# themes.zip needs actual extraction.
	unpack "${P}-themes.zip"
}

src_install() {
	local upstream_arch
	case ${ARCH} in
		amd64) upstream_arch=amd64 ;;
		arm64) upstream_arch=arm64 ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac

	newbin "${DISTDIR}/${P}-linux-${upstream_arch}" oh-my-posh

	# themes.zip has no top-level directory, so its contents land directly
	# in ${WORKDIR}; glob by extension only. Most themes are .omp.json,
	# but a few (e.g. devious-diamonds, glowsticks) ship as .omp.yaml.
	insinto /usr/share/oh-my-posh/themes
	doins *.omp.json *.omp.yaml

	dodoc "${FILESDIR}"/NOTICE.deps-31.2.1.txt

	local entry archive license_path docname
	for entry in "${GO_MODULE_LICENSES[@]}"; do
		archive=${entry%%|*}
		license_path=${entry#*|}
		docname="${archive%.zip}-${license_path##*/}"
		unzip -p "${DISTDIR}/${archive}" "${license_path}" > "${T}/${docname}" || die
		dodoc "${T}/${docname}"
	done

	# go.yaml.in/yaml/v3 (the compiled-in YAML module; formerly Canonical's
	# go-yaml, still copyright Canonical Ltd. per its own NOTICE) is
	# Apache-2.0 for the non-libyaml-ported files -- see NOTICE.deps.txt.
	# Apache-2.0 section 4(d) requires any NOTICE text a work distributes to be
	# preserved in redistributions; ship the module's actual upstream
	# NOTICE file verbatim rather than only summarizing its contents.
	newdoc "${FILESDIR}"/go.yaml.in-yaml-v3.NOTICE NOTICE.go.yaml.in-yaml-v3
}
