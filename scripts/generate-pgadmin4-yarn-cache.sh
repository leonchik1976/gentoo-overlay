#!/usr/bin/env bash
# Generate the Manifest-checked Yarn cache from the official pgAdmin release.
set -euo pipefail

if [[ $# != 1 || ! ${1##*/} =~ ^pgadmin4-([0-9]+\.[0-9]+)\.tar\.gz$ ]]; then
	echo "Usage: $0 /path/to/pgadmin4-VERSION.tar.gz" >&2
	exit 2
fi

version=${BASH_REMATCH[1]}
distfile=$(realpath "$1")
workspace="/tmp/codex/dev-db/pgadmin4-${version}"
mkdir -p "${workspace}"
scratch=$(mktemp -d "${workspace}/yarn-cache.XXXXXXXX")
trap 'rm -rf "${scratch}"' EXIT
cd "${scratch}"

tar xf "${distfile}"
source_dir="${scratch}/pgadmin4-${version}"
yarn_version=$(node -p "require('${source_dir}/web/package.json').packageManager.split('@')[1]")
runtime_yarn=$(node -p "require('${source_dir}/runtime/package.json').packageManager.split('@')[1]")
[[ ${yarn_version} == "${runtime_yarn}" && ${yarn_version} =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
curl -fsSL "https://registry.npmjs.org/@yarnpkg/cli-dist/-/cli-dist-${yarn_version}.tgz" -o yarn.tgz
tar xf yarn.tgz

export YARN_ENABLE_GLOBAL_CACHE=false YARN_ENABLE_TELEMETRY=0
export YARN_ENABLE_SCRIPTS=false ELECTRON_SKIP_BINARY_DOWNLOAD=1
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
yarn=( node "${scratch}/package/bin/yarn.js" )

cat >> "${source_dir}/web/.yarnrc.yml" <<'YAML'

supportedArchitectures:
  os: [linux]
  cpu: [x64, arm64]
  libc: [glibc]
YAML
(
	cd "${source_dir}/web"
	"${yarn[@]}" install --immutable --mode=skip-build
)
(
	cd "${source_dir}/runtime"
	"${yarn[@]}" workspaces focus --production
)

mkdir yarn-cache
for project in web runtime; do
	mv "${source_dir}/${project}/.yarn/cache" "yarn-cache/${project}"
	rm -f "yarn-cache/${project}/.gitignore"
done
output="${workspace}/pgadmin4-${version}-yarn-cache.tar"
LC_ALL=C tar --sort=name --mtime=@0 --owner=0 --group=0 --numeric-owner \
	--mode=u=rwX,go=rX -cf "${scratch}/cache.tar" yarn-cache
if [[ -e ${output} ]]; then
	cmp "${scratch}/cache.tar" "${output}"
else
	mv -n "${scratch}/cache.tar" "${output}"
fi
sha256sum "${output}"
