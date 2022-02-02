# Copyright 2020 The Cross-Media Measurement Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Repository rules/macros for rules_cue."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def rules_cue_dependencies():
    if "bazel_skylib" not in native.existing_rules():
        http_archive(
            name = "bazel_skylib",
            urls = [
                "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
                "https://github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
            ],
            sha256 = "c6966ec828da198c5d9adbaa94c05e3a1c7f21bd012a0b29ba8ddbccb2c93b0d",
        )
    if "cue_binaries_linux_amd64" not in native.existing_rules():
        cue_binaries(
            name = "cue_binaries_linux_amd64",
            platform = "linux_amd64",
            version = "0.4.1",
            sha256 = "d3f1df656101a498237d0a8b168a22253dde11f6b6b8cc577508b13a112142de",
        )
    if "cue_binaries_darwin_amd64" not in native.existing_rules():
        cue_binaries(
            name = "cue_binaries_darwin_amd64",
            platform = "darwin_amd64",
            version = "0.4.1",
            sha256 = "9904f316160803cb011b7ed7524626719741a609623fe89abf149ab7522acffd",
        )

def _cue_binaries_impl(rctx):
    version = rctx.attr.version
    sha256 = rctx.attr.sha256
    platform = rctx.attr.platform

    os_restriction = "@platforms//os:macos" if platform == "darwin_amd64" else "@platforms//os:linux"
    url = "https://github.com/cue-lang/cue/releases/download/v{version}/cue_v{version}_{platform}.tar.gz".format(
        version = version,
        platform = platform,
    )

    rctx.download_and_extract(
        url = url,
        sha256 = sha256,
    )
    rctx.template(
        "BUILD.bazel",
        Label("@wfa_rules_cue//cue:BUILD.external"),
        executable = False,
        substitutions = {
            "{os_restriction}": os_restriction,
        },
    )

cue_binaries = repository_rule(
    implementation = _cue_binaries_impl,
    attrs = {
        "platform": attr.string(
            mandatory = True,
            values = ["linux_amd64", "darwin_amd64"],
        ),
        "version": attr.string(mandatory = True),
        "sha256": attr.string(),
    },
)
