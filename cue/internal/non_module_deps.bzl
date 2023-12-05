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
