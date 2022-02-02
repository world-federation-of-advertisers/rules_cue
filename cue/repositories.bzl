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

    if "cue_binaries" not in native.existing_rules():
        cue_binaries(
            name = "cue_binaries",
            version = "0.4.1",
            sha256 = "d3f1df656101a498237d0a8b168a22253dde11f6b6b8cc577508b13a112142de",
        )

def _cue_binaries_impl(rctx):
    version = rctx.attr.version
    sha256 = rctx.attr.sha256

    url = "https://github.com/cue-lang/cue/releases/download/v{version}/cue_v{version}_linux_amd64.tar.gz".format(version = version)

    rctx.download_and_extract(
        url = url,
        sha256 = sha256,
    )
    rctx.template(
        "BUILD.bazel",
        Label("@wfa_rules_cue//cue:BUILD.external"),
        executable = False,
    )

cue_binaries = repository_rule(
    implementation = _cue_binaries_impl,
    attrs = {"version": attr.string(mandatory = True), "sha256": attr.string()},
)
