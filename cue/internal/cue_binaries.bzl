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
        Label("//cue/internal:BUILD.external"),
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
