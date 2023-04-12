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
    """Declares repository targets for dependencies of rules_cue."""
    if "platforms" not in native.existing_rules():
        http_archive(
            name = "platforms",
            urls = [
                "https://mirror.bazel.build/github.com/bazelbuild/platforms/releases/download/0.0.4/platforms-0.0.4.tar.gz",
                "https://github.com/bazelbuild/platforms/releases/download/0.0.4/platforms-0.0.4.tar.gz",
            ],
            sha256 = "079945598e4b6cc075846f7fd6a9d0857c33a7afc0de868c2ccb96405225135d",
        )
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
            version = "0.5.0-rc.1",
            sha256 = "92425c4e60e78d1a372ceb7ca5c900db30c170fd35ad8fdcd1da06b379864436",
        )
    if "cue_binaries_darwin_amd64" not in native.existing_rules():
        cue_binaries(
            name = "cue_binaries_darwin_amd64",
            platform = "darwin_amd64",
            version = "0.5.0-rc.1",
            sha256 = "80a686353cda881d3a4f18658837eebf1a8b203e65f62bafd317821d7f64ae08",
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
