# Project Guidelines

## Overview

This is a Snakemake workflow for building genome reference libraries for NGS
pipelines. It has two stages: pulling reference resources (`pull_resources.smk`)
and building indices (`build_indices.smk`). Both are orchestrated via a unified
`workflow/Snakefile`.

## Languages and File Types

- **Snakemake rules** (`.smk`): Workflow definitions in `workflow/rules/`
- **Python** (`.py`): Helper scripts in `workflow/scripts/`
- **R** (`.R`): Annotation scripts in `workflow/scripts/`
- **Shell** (`.sh`): Wrapper scripts in `workflow/scripts/`
- **YAML** (`.yaml`): Configuration and conda environment definitions
- **TOML** (`.toml`): Project configuration (`pixi.toml`)
- **Markdown** (`.md`): Documentation

## Code Style

Each language has an enforced formatter. Run `pixi run style` to format all
files, or `pixi run lint` to check without modifying.

| Language  | Formatter  | Config / Notes                        |
| --------- | ---------- | ------------------------------------- |
| Snakemake | `snakefmt` | Applied to `workflow/`                |
| Python    | `black`    | Default settings                      |
| R         | `styler`   | Applied to `workflow/`                |
| Shell     | `shfmt`    | 4-space indent (`shfmt --indent 4`)   |
| Markdown  | `mdformat` | With `gfm`, `shfmt`, `tables` plugins |
| YAML      | `yamlfmt`  | Default settings                      |
| TOML      | `tombi`    | Default settings                      |

All shell scripts must start with `#!/usr/bin/env bash` and use
`set -euo pipefail`.

## Snakemake Conventions

- Minimum Snakemake version is declared in `pixi.toml`
- New or modified rules should include a docstring describing inputs, outputs,
  and params
- Rules are organized in `workflow/rules/` in tool-specific files (e.g.
  `star.smk`, `salmon.smk`). New index rules should be added in a tool-specific
  rule file under `workflow/rules/` and the file should be included from
  `workflow/Snakefile`; their outputs must be added to
  `get_build_indices_output()` in `common.smk`. New resource rules go in
  `pull_resources.smk` and their outputs must be added to
  `get_pull_resources_output()` in `common.smk`
- Rules should specify both `conda:` (environment YAML in `workflow/envs/`) and
  `container:` (from `config/container_config.yaml`) directives for software
  deployment. Access container URIs via `config["container"].get("<tool>")`
- Use `config["key"]` to access configuration. Defaults are set in
  `workflow/schemas/config.schema.yaml`.
- Log files go under `logs/`. Prefer the pattern `logs/<tool>/<rule-name>.log`
  for new rules, but existing top-level `logs/<rule-name>.log` paths are also
  accepted where appropriate
- Use `storage()` for remote file inputs (HTTP downloads)

## Build and Test

```sh
pixi shell             # Enter development environment
pixi run unittest      # Run dry-run tests (pytest-workflow)
pixi run style         # Auto-format all files
pixi run lint          # Check formatting (used in CI)
pixi run documentation # Build MkDocs site
```

Tests are defined in `tests/test_dryrun.yaml` using pytest-workflow. They
validate Snakemake syntax via dry-runs (`snakemake -n`), not runtime
correctness. The `lint` task additionally runs `snakemake --lint` to check rule
best practices (log directives, shell quoting, etc.).

## Project Structure

```
config/              # Default and container configuration YAML
workflow/
  Snakefile          # Unified entrypoint (includes all rule files)
  rules/             # Snakemake rule definitions (.smk)
    common.smk       # Shared helper functions and output collectors
  scripts/           # Python, R, and shell helper scripts
  schemas/           # Validation schemas.
  envs/              # Conda environment definitions per tool
  profiles/          # Snakemake execution profiles
  resources/         # Static data files shipped with the workflow
tests/               # pytest-workflow test definitions and fixtures
docs/                # MkDocs documentation source
```

## Configuration

- `workflow/schemas/config.schema.yaml`: Default workflow parameters (organism,
  release, genome build, URLs, chromosome filters) and validation.
- `config/container_config.yaml`: Docker/Apptainer container URIs per tool,
  accessed in rules as `config["container"].get("<tool>")`
- Supports human (GRCh38) and mouse (GRCm38, GRCm39) organisms

## Commits

Write atomic commits: each commit must be a single, self-contained, logical
change that leaves the workflow in a valid state. Do not bundle unrelated
changes.

Follow the Conventional Commits standard for commit messages:

```
<type>(<scope>): <subject>
                                        ← blank line
<body>                                  ← optional
                                        ← blank line
<footer>                                ← optional
```

Type must be one of: feat, fix, docs, style, refactor, test, chore, ci, build,
perf. Use feat! or fix! (with !) or a BREAKING CHANGE: footer for breaking
changes.

Scope should identify the affected component, e.g. star, salmon, pull_resources,
common, config, docs, ci.

### Subject line rules (the 50/72 rule):

- Keep the subject line (first line) to 50 characters or fewer
- Use the imperative mood ("add feature" not "added feature")
- Do not end with a period
- Do not capitalize the first word after the colon (the type and scope
  themselves follow Conventional Commits casing)

### Body rules:

- Wrap body text at 72 characters per line
- Explain what changed and why, not how
- Separate from the subject with a blank line

Examples:

```
feat(salmon): add gentrome index generation
```

```
fix(pull_resources): handle missing gnomAD chromosomes

Some gnomAD VCF files may not contain all chromosomes
listed in the config. Skip missing chromosomes instead of
failing the entire download step.
```

```
refactor(common)!: split output collectors by organism

BREAKING CHANGE: get_pull_resources_output now requires
an organism parameter instead of reading from global config.
```
