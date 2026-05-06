# Developer Guide

## Release

Before creating a new release make sure to do the following steps:

* If new resources are pulled or new indices are created: Add the description to the documentation
* Update CHANGELOG.md

## Tests

Currently, CI tests include dry-runs of the pull_resources and build_indices
workflow. These tests check, if the syntax is correct but do not detect errors
that occur during runtime.

To run the tests locally execute (in the pixi shell):

```
make unittest
```

## Software environment

Currently we use [Pixi](https://pixi.prefix.dev/latest/) to manage the software
environments used to run and develop the pipeline. See
[Pixi pack](https://pixi.prefix.dev/latest/deployment/pixi_pack/) on how to
make software environments available in environments where Pixi is not
available.

## Contribute

See [CONTRIBUTING.md](https://github.com/TRON-Private/tronmake-genome-lib-builder/blob/main/CONTRIBUTING.md).
