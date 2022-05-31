"@generated by @aspect_rules_js//js/private:translate_pnpm_lock.bzl from pnpm lock file @//:pnpm-lock.yaml"

load("@bazel_skylib//lib:paths.bzl", _paths = "paths")
load("@npm__rollup__2.70.2__links//:link_js_package.bzl", link_1 = "link_js_package")

# buildifier: disable=unnamed-macro
def link_js_packages():
    "Generated list of link_js_package() target generators and first-party linked packages corresponding to the packages in @//:pnpm-lock.yaml"
    root_package = ""
    importer_paths = ["."]
    is_root = native.package_name() == root_package
    is_direct = False
    for import_path in importer_paths:
        importer_package_path = _paths.normalize(_paths.join(root_package, import_path))
        if importer_package_path == ".":
            importer_package_path = ""
        if importer_package_path == native.package_name():
            is_direct = True
    if not is_root and not is_direct:
        msg = "The link_js_packages() macro loaded from @npm//:defs.bzl and called in bazel package '%s' may only be called in the bazel package(s) corresponding to the root package '' and packages corresponding to importer paths ['.']" % native.package_name()
        fail(msg)

    link_1(name = "direct__rollup", direct = None, fail_if_no_link = False)
