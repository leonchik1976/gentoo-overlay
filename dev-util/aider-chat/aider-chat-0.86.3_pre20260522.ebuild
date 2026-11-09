# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# distutils-r1 and python-single-r1 do not yet support EAPI 9.
EAPI=8

DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{13..14} )

inherit distutils-r1

DESCRIPTION="AI pair programming in your terminal with local and cloud LLMs"
HOMEPAGE="
	https://aider.chat/
	https://github.com/Aider-AI/aider/
	https://pypi.org/project/aider-chat/
"

# Contains upstream's Python 3.13/3.14 compatibility commit 975e5a899168.
AIDER_COMMIT=5dc9490bb35f9729ef2c95d00a19ccd30c26339c
SRC_URI="https://github.com/Aider-AI/aider/archive/${AIDER_COMMIT}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/aider-${AIDER_COMMIT}"

export SETUPTOOLS_SCM_PRETEND_VERSION="${PV/_pre/.dev}"

# Only the MIT-licensed queries used by ::gentoo's grep-ast are installed.
LICENSE="Apache-2.0 MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Match the LiteLLM version in this upstream snapshot's requirements.txt.
# Permit NumPy 2.5 and SciPy 1.18 after offline repository-map/unit validation;
# upstream's tighter bounds would conflict with installed Python 3.15 consumers.
RDEPEND="${RDEPEND}
	~dev-python/litellm-1.82.3[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/backoff[${PYTHON_USEDEP}]
		dev-python/beautifulsoup4[${PYTHON_USEDEP}]
		dev-python/configargparse[${PYTHON_USEDEP}]
		dev-python/diff-match-patch[${PYTHON_USEDEP}]
		dev-python/diskcache[${PYTHON_USEDEP}]
		dev-python/flake8[${PYTHON_USEDEP}]
		dev-python/gitpython[${PYTHON_USEDEP}]
		dev-python/grep-ast[${PYTHON_USEDEP}]
		dev-python/httpx[${PYTHON_USEDEP}]
		dev-python/json5[${PYTHON_USEDEP}]
		dev-python/jsonschema[${PYTHON_USEDEP}]
		dev-python/networkx[${PYTHON_USEDEP}]
		>=dev-python/numpy-2.3[${PYTHON_USEDEP}]
		<dev-python/numpy-2.6[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
		dev-python/pathspec[${PYTHON_USEDEP}]
		dev-python/pexpect[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
		dev-python/posthog[${PYTHON_USEDEP}]
		dev-python/prompt-toolkit[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
		dev-python/pydub[${PYTHON_USEDEP}]
		dev-python/pygments[${PYTHON_USEDEP}]
		dev-python/pypandoc[${PYTHON_USEDEP}]
		dev-python/pyperclip[${PYTHON_USEDEP}]
		dev-python/python-dotenv[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/rich[${PYTHON_USEDEP}]
		>=dev-python/scipy-1.16.1[${PYTHON_USEDEP}]
		<dev-python/scipy-1.19[${PYTHON_USEDEP}]
		dev-python/shtab[${PYTHON_USEDEP}]
		dev-python/socksio[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
		>=dev-python/tree-sitter-0.25.2[${PYTHON_USEDEP}]
		dev-python/watchfiles[${PYTHON_USEDEP}]
	')
"
BDEPEND="${BDEPEND}
	$(python_gen_cond_dep '
		>=dev-python/setuptools-77[${PYTHON_USEDEP}]
		>=dev-python/setuptools-scm-8[${PYTHON_USEDEP}]
	')
"

PATCHES=(
	"${FILESDIR}/aider-chat-0.86.2-stdlib.patch"
	"${FILESDIR}/aider-chat-0.86.2-portage.patch"
	"${FILESDIR}/${P}-metadata.patch"
	"${FILESDIR}/aider-chat-0.86.2-tests.patch"
	"${FILESDIR}/${P}-tests.patch"
)

EPYTEST_PLUGINS=( pytest-env pytest-socket )
distutils_enable_tests pytest

python_prepare_all() {
	# Replace the pip lockfile with the Portage dependency graph.
	cp "${FILESDIR}/${P}-requirements.txt" requirements.txt || die
	cp "${FILESDIR}/query-licenses.txt" QUERY-LICENSES.txt || die
	distutils-r1_python_prepare_all

	# ::gentoo's grep-ast uses separate system grammars, not the bundled
	# tree-sitter-language-pack. Keep only the queries its adapter can use.
	local query
	for query in aider/queries/tree-sitter-language-pack/*-tags.scm; do
		case ${query##*/} in
			c-tags.scm|cpp-tags.scm|javascript-tags.scm|python-tags.scm) ;;
			*) rm "${query}" || die ;;
		esac
	done
	rm -r aider/queries/tree-sitter-languages || die
}

python_test() {
	# Optional browser, semantic-help, and audio integrations are not part
	# of the CLI test target. Provider requests are mocked by the unit tests.
	local EPYTEST_IGNORE=(
		tests/basic/test_voice.py
		# Checks the public documentation URLs over the network.
		tests/basic/test_urls.py
	)
	# These assertions depend on retired model identifiers or fixed provider
	# metadata which differs in the packaged LiteLLM version.
	local EPYTEST_DESELECT=(
		tests/basic/test_commands.py::TestCommands::test_cmd_read_only_with_image_file
		tests/basic/test_commands.py::TestCommands::test_cmd_tokens_output
		tests/basic/test_models.py::TestModels::test_max_context_tokens
	)
	local -x AIDER_ANALYTICS=false
	local -x LITELLM_LOCAL_MODEL_COST_MAP=True
	local -x TERM=xterm
	epytest --disable-socket tests/basic
}

python_install_all() {
	distutils-r1_python_install_all
	dodoc QUERY-LICENSES.txt
	newdoc "${FILESDIR}/README.development.gentoo" README.gentoo
}

pkg_postinst() {
	elog "See /usr/share/doc/${PF}/README.gentoo* for parser coverage and optional features."
	elog "For Ollama: set OLLAMA_API_BASE and use aider --model ollama_chat/<model>."
}
