## TronMake Genome Lib Builder

<!-- badges: start -->

[![Snakemake](https://img.shields.io/badge/snakemake-8.25.3-brightgreen.svg?style=plastic)](https://snakemake.readthedocs.io)
[![pipeline status](https://github.com/TRON-Private/tronmake-genome-lib-builder/actions/workflows/ci.yaml/badge.svg)](https://github.com/TRON-Private/tronmake-genome-lib-builder/actions/workflows/ci.yaml)

<!-- badges: end -->

The **TRON Genome Library** is a unified resource collection used by next generation sequencing (NGS) analysis pipelines developed by the computational medicine group at [TRON](https://github.com/TRON-Bioinformatics). The TronMake Genome Lib Builder system is leveraged for preparing a reference genome and annotation set for use with SnakeMake and NextFlow based pipelines, including cancer-specific alternative splicing and somatic mutation discovery. The genome resource building process creates a unified annotation set based on GENCODE reference annotation and the GATK resource bundle (hg38). The workflow is implemented in SnakeMake (Mölder et al., 2021) for reproducible downloading and building of genome resource data. 

Documentation: https://urban-guacamole-qmm473j.pages.github.io/

The following pipelines are compatible with the TRON Genome Library:

- TronFlow
    + [tronflow-alignment](https://github.com/TRON-Bioinformatics/tronflow-alignment)
    + [tronflow-strelka2](https://github.com/TRON-Bioinformatics/tronflow-strelka2)
    + [tronflow-mutect2](https://github.com/TRON-Bioinformatics/tronflow-mutect2)
    + [tronflow-haplotype-caller](https://github.com/TRON-Bioinformatics/tronflow-haplotype-caller)
    + [tronflow-bam-preprocessing](https://github.com/TRON-Bioinformatics/tronflow-bam-preprocessing)

- [splice2neo](https://github.com/TRON-Bioinformatics/splice2neo)

Pre-built TRON Genome Libraries will be available for download for you to use and cite.

## Installation

Clone the repository:

```
git clone https://gitlab.rlp.net/tron/tronmake-genome-lib-builder.git
cd tronmake-genome-lib-builder
```

Enter a shell environment containing snakemake:

```
pixi shell
``` 

## Usage

The workflow consists of two stages. 

1. Pulling resource data from Gencode, UCSC and GATK.

```
snakemake -s workflow/pull_resources.smk \
    --directory </path/to/output/directory> \
    --software-deployment-method conda \
    --latency-wait 60 \
    [--configfile <path/to/config/file>] \
    [--conda-prefix </path/to/shared/conda/>] \
    [--profile </path/to/cluster/profile/>]
```

2. Building genome indices

```
snakemake -s workflow/build_indices.smk \
    --directory </path/to/output/directory> \
    --software-deployment-method conda \
    --latency-wait 60 \
    [--configfile <path/to/config/file>] \
    [--conda-prefix </path/to/shared/conda/>] \
    [--profile </path/to/cluster/profile/>]
```

Both stages can be executed independently from each other. We recommend to build 
the genome library using the default resources pulled by `workflow/pull_resources.smk`
by setting `--directory` in the build_indices step to the same path that was
used for the `pull_resources` step. However, you can also download your own genome 
data and start with `workflow/build_indices.smk`.

## Authors & Acknowledgements 

The TronMake Genome Lib Builder was originally developed by Luis Kress and Johannes Hausmann at [TRON - Translational Oncology at the Medical Center of the Johannes Gutenberg University Mainz gGmbH (non-profit)](https://tron-mainz.de/).

Maintenance is now lead by Luis Kress and Johannes Hausmann. 

Main developers: 

- [Luis Kress](mailto:luis.kress@tron-mainz.de)
- [Johannes Hausmann](mailto:johannes.hausmann@tron-mainz.de)
- [Jonas Freimuth](mailto:jonas.freimuth@tron-mainz.de)

## References

* Mölder F, Jablonski KP, Letcher B et al. Sustainable data analysis with Snakemake [version 1; peer review: 1 approved, 1 approved with reservations]. F1000Research 2021, 10:33 (https://doi.org/10.12688/f1000research.29032.1) 