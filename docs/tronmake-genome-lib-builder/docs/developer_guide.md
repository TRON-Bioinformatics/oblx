# Developer Guide

## Release

Before creating a new release, make sure to update the docs if new resources are
pulled or new indices are created. The rest should be handled via
`release-please`. To make that work, ensure that commits follow the
[conventional commits standard](https://www.conventionalcommits.org).

## Tests

Currently, CI tests include dry-runs of the pull_resources and build_indices
workflow. These tests check, if the syntax is correct but do not detect errors
that occur during runtime.

To run the tests locally execute (in the pixi shell):

```
pixi run unittest
```

## Software environment

Currently we use [Pixi](https://pixi.prefix.dev/latest/) to manage the software
environments used to run and develop the pipeline. See
[Pixi pack](https://pixi.prefix.dev/latest/deployment/pixi_pack/) on how to make
software environments available in environments where Pixi is not available.

## Code styling

To ensure code and docs are correctly formatted, run `pixi run style` (or, if
you are only interested in certain filetypes, the subtasks). Running
`pixi run lint` will in turn check if all files are correctly formatted without
changing anything, but rather exit with a non-zero exit code in that case. It is
mainly used for CI tasks.

## Contribute

See
[CONTRIBUTING.md](https://github.com/TRON-Private/tronmake-genome-lib-builder/blob/main/CONTRIBUTING.md).
