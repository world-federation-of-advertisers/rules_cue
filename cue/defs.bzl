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

"""Build defs for CUE.

See https://cuelang.org/
"""

def _cue_string_field_impl(ctx):
    if len(ctx.files.srcs) != 1:
        fail("Expected exactly one input file in srcs")
    input = ctx.files.srcs[0]

    package = ctx.attr.package
    if not package:
        package = ctx.label.package.replace("/", "_")

    output = ctx.actions.declare_file(ctx.label.name + ".cue")

    args = ctx.actions.args()
    args.add(package)
    args.add(ctx.attr.identifier)
    args.add(input)
    args.add(output)

    ctx.actions.run(
        outputs = [output],
        inputs = [input],
        executable = ctx.executable._gen_cue_string_field,
        arguments = [args],
    )

    return [DefaultInfo(files = depset([output]))]

cue_string_field = rule(
    doc = "Generates a CUE file with a string field containing file contents.",
    implementation = _cue_string_field_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = "Single input file whose contents should be the field value.",
            allow_files = True,
            mandatory = True,
        ),
        "identifier": attr.string(
            doc = "CUE identifier for the string field.",
            mandatory = True,
        ),
        "package": attr.string(
            doc = "CUE package. Defaults to the Bazel package name separated by underscores.",
        ),
        "_gen_cue_string_field": attr.label(
            executable = True,
            cfg = "exec",
            default = "@wfa_rules_cue//cue:gen-cue-string-field",
        ),
    },
)

CueInfo = provider("CUE library info.", fields = ["transitive_sources"])

def _get_transitive_sources(srcs, deps):
    return depset(
        srcs,
        transitive = [dep[CueInfo].transitive_sources for dep in deps],
    )

def _cue_library_impl(ctx):
    return [CueInfo(transitive_sources = _get_transitive_sources(
        ctx.files.srcs,
        ctx.attr.deps,
    ))]

cue_library = rule(
    implementation = _cue_library_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = "Source CUE files.",
            allow_files = [".cue"],
            allow_empty = False,
        ),
        "deps": attr.label_list(
            doc = "cue_library dependencies.",
            providers = [CueInfo],
        ),
    },
)

def _cue_export_impl(ctx):
    if len(ctx.files.srcs) == 0 and len(ctx.attr.deps) == 0:
        fail("Expected to have srcs or deps")

    outfile = ctx.actions.declare_file(
        ".".join((ctx.label.name, ctx.attr.filetype)),
    )
    transitive_sources = _get_transitive_sources(ctx.files.srcs, ctx.attr.deps)

    args = ctx.actions.args()
    args.add("export")
    args.add("--outfile", outfile)
    args.add("--out", ctx.attr.filetype)
    if ctx.attr.expression:
        args.add("--expression", ctx.attr.expression)
    args.add_all(transitive_sources)

    tags = ctx.attr.cue_tags or {}
    for k, v in tags.items():
        args.add(
            "-t",
            "%s=%s" % (k, ctx.expand_make_variables("cue_tags", v, {})),
        )

    ctx.actions.run(
        outputs = [outfile],
        inputs = transitive_sources.to_list(),
        executable = ctx.executable._cue_cli,
        mnemonic = "CueExport",
        arguments = [args],
    )

    return [DefaultInfo(files = depset([outfile]))]

cue_export = rule(
    implementation = _cue_export_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = "Source CUE files.",
            allow_files = [".cue"],
            allow_empty = True,
        ),
        "deps": attr.label_list(
            doc = "cue_library dependencies.",
            providers = [CueInfo],
            allow_empty = True,
        ),
        "filetype": attr.string(
            doc = "Output filetype.",
            default = "yaml",
            values = ["yaml", "json"],
        ),
        "expression": attr.string(),
        "cue_tags": attr.string_dict(
            doc = "Dict of CUE tags to values. Values subject to 'Make variable' substitution.",
        ),
        "_cue_cli": attr.label(
            default = "@wfa_rules_cue//cue:cue_cli",
            executable = True,
            cfg = "exec",
        ),
    },
)
