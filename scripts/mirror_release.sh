#!/usr/bin/env bash
set -o errexit -o nounset
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

version="${1:-$(curl --silent "https://registry.npmjs.org/rollup/latest" | jq --raw-output ".version")}"
out="$SCRIPT_DIR/../rollup/private/v${version}"
mkdir -p "$out"

cd $(mktemp -d)
npx pnpm install "rollup@$version" --lockfile-only
touch BUILD
cat >WORKSPACE <<EOF
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "aspect_rules_js",
    sha256 = "a6d31c98f30eb503e836201d723b3164c5e07ba34553d260f71720a819d8ba4c",
    strip_prefix = "rules_js-1.0.0-rc.2",
    url = "https://github.com/aspect-build/rules_js/archive/refs/tags/v1.0.0-rc.2.tar.gz",
)
load("@aspect_rules_js//js:repositories.bzl", "rules_js_dependencies")

rules_js_dependencies()

load("@rules_nodejs//nodejs:repositories.bzl", "nodejs_register_toolchains")

nodejs_register_toolchains(
    name = "nodejs",
    node_version = "16.9.0",
)

load("@aspect_bazel_lib//lib:repositories.bzl", "DEFAULT_YQ_VERSION", "register_yq_toolchains")

register_yq_toolchains(
    version = DEFAULT_YQ_VERSION,
)

load("@aspect_rules_js//npm:npm_import.bzl", "npm_translate_lock")

npm_translate_lock(
    name = "npm",
    pnpm_lock = "//:pnpm-lock.yaml",
    # fsevents is an optional dependency and is broken on macos
    # with a duplicate action.
    # We think this isn't even a useful feature under Bazel which
    # has its own file watching.
    no_optional = True,
)

load("@npm//:repositories.bzl", "npm_repositories")

npm_repositories()
EOF
bazel fetch @npm//:all
cp $(bazel info output_base)/external/npm/{defs,repositories}.bzl "$out"
echo "Mirrored rollup version $version to $out. Now add it to rollup/private/versions.bzl"
