<p align="center">
    <img src="resources/logo.png" alt="logo" width="25%">
</p>

## OBLX: Omics builder for Bioinformatics resource Libraries and indeXes

<!-- badges: start -->

[![Snakemake](https://img.shields.io/badge/snakemake-9.20.0-brightgreen.svg?style=plastic)](https://snakemake.readthedocs.io)
[![pipeline status](https://github.com/TRON-Private/tronmake-genome-lib-builder/actions/workflows/ci.yaml/badge.svg)](https://github.com/TRON-Private/tronmake-genome-lib-builder/actions/workflows/ci.yaml)

<!-- badges: end -->

Documentation: https://urban-guacamole-qmm473j.pages.github.io/

<p align="center">
    <img src="resources/workflow_graph.png" width="60%">
</p>

**OBLX** is a Snakemake (Mölder et al., 2021) pipeline which downloads reference
genomes, genome annotations and further resources, and generates from these the
indices required for various bioinformatics tools and pipelines. The pipeline
consists of two independently executable stages:
[*Download Resources*](pull_resources.md#download-resources) and
[*Build Indices*](build_indices.md#build-indices). *Download Resources*
retrieves the reference genome, genome annotation and other resources and
prepares the data for bioinformatics index generation. The reference genome and
genome annotation are downloaded from [GENCODE](https://www.gencodegenes.org/);
the preferred genome assembly version, GENCODE release and organism can be
specified via the [config file](configuration.md). Additional resources from
GATK, UCSC and gnomAD are retrieved (see
[*Download Resources*](pull_resources.md#download-resources) for details).
*Build Indices* then generates tool-specific indices. The resulting genome
library is consistent with respect to chromosome, transcript and gene naming and
supports an extensive set of bioinformatics tools, all listed in
[Supported Tools](supported_tools.md#supported-bioinformatics-tools).

## Installation

Clone the repository:

```
git clone https://github.com/TRON-Private/tronmake-genome-lib-builder.git
```

Install Snakemake (see
[https://snakemake.readthedocs.io](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html))
and pandas (see
[https://pandas.pydata.org](https://pandas.pydata.org/docs/getting_started/install.html)).

> Note: We recommend using pixi
> ([https://pixi.prefix.dev/](https://pixi.prefix.dev/)) to replicate the
> environment used in the tests. Therefore, install pixi and run `pixi shell`.

## Usage

The stages [*Download Resources*](pull_resources.md#download-resources) and
[*Build Indices*](build_indices.md#build-indices) are run consecutively when
executing (to run them independently, see the respective section):

```
snakemake -s workflow/Snakefile \
  --directory </path/to/output/directory> \
  --software-deployment-method [conda|apptainer] \
  --latency-wait 60 \
  [--configfile <path/to/config/file>] \
  [--profile </path/to/cluster/profile/>]
```

- `--directory`: Directory where the results of the workflow should be stored.
- `--software-deployment-method`: Either `conda` or `apptainer`. Container
  images for apptainer are configured in
  [`config/container_config.yaml`](configuration.md).
- `--latency-wait`: Seconds to wait for files to appear (recommended `60` to
  account for IO latency of large files).
- `--configfile` (optional): Override default configuration, e.g. organism or
  reference genome version. See [Configuration](configuration.md).
- `--profile` (optional): Snakemake cluster profile, e.g. to submit jobs to an
  HPC scheduler.

## Input

OBLX does not require any user-provided input. You only specify the output
directory and, if non-default settings are desired, adapt the
[configuration](configuration.md#configuration).

## Output

The output of the pipeline is written to the directory specified with
`--directory`. Descriptions of the downloaded genome resources are documented in
[*Download Resources*](pull_resources.md#download-resources); descriptions of
the generated indices are documented in
[*Build Indices*](build_indices.md#build-indices).

## Supported bioinformatics tools

See [Supported Tools](supported_tools.md#supported-bioinformatics-tools).

## About

OBLX was originally developed by Luis Kress and Johannes Hausmann at
[TRON - Translational Oncology at the Medical Center of the Johannes Gutenberg University Mainz gGmbH (non-profit)](https://tron-mainz.de/).

Main developers:

- [Luis Kress](mailto:luis.kress@tron-mainz.de)
- [Johannes Hausmann](mailto:johannes.hausmann@tron-mainz.de)
- [Jonas Freimuth](mailto:jonas.freimuth@tron-mainz.de)

## References

- Mölder F, Jablonski KP, Letcher B et al. Sustainable data analysis with
  Snakemake [version 1; peer review: 1 approved, 1 approved with reservations].
  F1000Research 2021, 10:33 (https://doi.org/10.12688/f1000research.29032.1)
