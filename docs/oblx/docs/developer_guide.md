# Developer Guide

## Software environment

The project uses [Pixi](https://pixi.prefix.dev/latest/) to manage all
development and runtime environments. After installing Pixi, enter the project
shell with:

```
pixi shell
```

This provides Snakemake and all dependencies needed to run the pipeline. For
deployments to systems without internet access or without Pixi, see
[Pixi pack](https://pixi.prefix.dev/latest/deployment/pixi_pack/).

The available Pixi environments and tasks are defined in
[`pixi.toml`](https://github.com/TRON-Private/tronmake-genome-lib-builder/blob/dev/pixi.toml).
The most relevant tasks are:

| Task                     | Description                                                          |
| ------------------------ | -------------------------------------------------------------------- |
| `pixi run unittest`      | Run the test suite (see [Tests](#tests)).                            |
| `pixi run lint`          | Run all linters (Snakemake, Python, R, Markdown, shell, YAML, TOML). |
| `pixi run style`         | Auto-format all files (same scope as `lint`).                        |
| `pixi run lint-workflow` | Snakemake `--lint` of `workflow/Snakefile`.                          |
| `pixi run documentation` | Build the MkDocs site under `docs/oblx/`.                            |
| `pixi run pin-rule-envs` | Pin conda environments in `workflow/envs/*.yaml` with snakedeploy.   |

## Tests

CI currently includes dry-runs of the `pull_resources` and `build_indices`
workflows. These verify workflow syntax and rule wiring but do **not** detect
runtime errors of the underlying tools.

Run the tests locally with:

```
pixi run unittest
```

## Adding a new index or resource

The workflow's final output is collected by two helpers in
[`workflow/rules/common.smk`](https://github.com/TRON-Private/tronmake-genome-lib-builder/blob/dev/workflow/rules/common.smk):
`get_pull_resources_output` and `get_build_indices_output`. To extend the
pipeline:

1. Add a rule to the appropriate file under `workflow/rules/` (e.g. a new
   `<tool>.smk` for an index, or an addition to `pull_resources.smk` for a new
   resource).
1. Register the new output file(s) in `get_build_indices_output` or
   `get_pull_resources_output` so they are produced by the default target.
1. Define the required conda environment (if not already present), add it under
   `workflow/envs/` and run `pixi run pin-rule-envs` to pin its dependencies.
1. Define the required container (if not already present) and add it to
   [`config/container_config.yaml`](https://github.com/TRON-Private/tronmake-genome-lib-builder/blob/dev/config/container_config.yaml).
1. Document the new output in `pull_resources.md` / `build_indices.md` and add a
   row to the matching `docs/.../resources/*.tsv` table.

## Code styling

Run `pixi run style` to auto-format code and docs. `pixi run lint` performs the
same checks without modifying files and exits non-zero on failure; it is used in
CI. Sub-tasks (`style-python`, `lint-snakemake`, ...) are available for
individual file types — see
[`pixi.toml`](https://github.com/TRON-Private/tronmake-genome-lib-builder/blob/dev/pixi.toml).

## Release

Before creating a new release:

- If new resources are pulled or new indices are created, ensure they are
  documented (including the matching row in
  `docs/oblx/docs/resources/{human,mouse}_resources.tsv` or
  `supported_tools.tsv`).
- Update `CHANGELOG.md`.
- Bump the version in
  [`pixi.toml`](https://github.com/TRON-Private/tronmake-genome-lib-builder/blob/dev/pixi.toml).

## Contribute

[CONTRIBUTING.md](https://github.com/TRON-Private/tronmake-genome-lib-builder/blob/main/CONTRIBUTING.md).
