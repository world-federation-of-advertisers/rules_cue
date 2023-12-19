# Copyright 2023 The Cross-Media Measurement Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Module extension for non-module dependencies."""

load("//cue/internal:cue_binaries.bzl", "cue_binaries")

def _non_module_deps_impl(
        # buildifier: disable=unused-variable
        mctx):
    if "cue_binaries_linux_amd64" not in native.existing_rules():
        cue_binaries(
            name = "cue_binaries_linux_amd64",
            platform = "linux_amd64",
            version = "0.5.0",
            sha256 = "38c9a2f484076aeafd9f522efdee40538c31337539bd8c80a29f5c4077314e53",
        )
    if "cue_binaries_darwin_amd64" not in native.existing_rules():
        cue_binaries(
            name = "cue_binaries_darwin_amd64",
            platform = "darwin_amd64",
            version = "0.5.0",
            sha256 = "00fc991977232240893ae36dc852366af859214d6e1b2b9e03e93b8f9f0991a7",
        )

non_module_deps = module_extension(implementation = _non_module_deps_impl)
