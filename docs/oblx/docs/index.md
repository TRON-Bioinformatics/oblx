<p align="center">
    <img src="resources/workflow_graph.png" width="50%"
    alt="Brief visual description of OBLX, showing which resources are downloaded, which tool indices are created, for which purpose, and if that is for human usage only.">
</p>

**OBLX** (/ˌɒbl.ˈɛks/) is a Snakemake (Mölder et al., 2021) pipeline which
downloads reference genomes, genome annotations and further resources, and
generates from these resources several indices required for various
bioinformatics tools. The pipeline consists of two independently executable
steps: [*Download Resources*](pull_resources.md#download-resources) and
[*Build Indices*](build_indices.md#build-indices). *Download Resources*
retrieves the resources and prepares the data for bioinformatics index
generation. The reference genome and genome annotation are downloaded from
[GENCODE](https://www.gencodegenes.org/). The preferred genome assembly version,
GENCODE release and organism can be specified via the
[config file](configuration.md). Additional resources are retrieved from GATK,
UCSC and gnomAD (see
[*Download Resources*](pull_resources.md#download-resources) for details).
*Build Indices* then generates tool-specific indices. The resulting genome
library is consistent with respect to chromosome, transcript and gene naming and
supports an extensive set of bioinformatics tools, all listed in
[Supported Tools](supported_tools.md#supported-bioinformatics-tools).

## Pre-built indices

Pre-built OBLX libraries for **human GRCh38 v49** and **mouse GRCm39 vM36** are
available for download via
[ftp://easyfuse.tron-mainz.de/tron_genome_library](ftp://easyfuse.tron-mainz.de/tron_genome_library).

```sh
# human
wget ftp://easyfuse.tron-mainz.de/oblx/v1.0.0/human/GRCh38_49

# mouse
wget ftp://easyfuse.tron-mainz.de/oblx/v1.0.0/mouse/GRCm39_M36
```

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

The steps [*Download Resources*](pull_resources.md#download-resources) and
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

- `--directory`: Directory to store the results of the workflow.
- `--software-deployment-method`: Either `conda` or `apptainer`. Container
  images for apptainer are configured in
  [`config/container_config.yaml`](configuration.md).
- `--latency-wait`: Seconds to wait for files to appear (recommended `60` to
  account for IO latency of large files).
- `--configfile` (optional): Overrides default configuration if provided, e.g.
  organism or reference genome version. See [Configuration](configuration.md).
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

## Contribution

We welcome contributions! Please see
[CONTRIBUTING](https://github.com/TRON-Bioinformatics/OBLX/CONTRIBUTING.md) and
[developer_guide](developer_guide.md) for guidelines.

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
- Figure generated with [BioRender](https://app.biorender.com/) icons.
