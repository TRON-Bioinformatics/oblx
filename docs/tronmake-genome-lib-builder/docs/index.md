# TronMake Genome Lib Builder

<!-- badges: start -->

[![Release](https://gitlab.rlp.net/tron/tronmake-genome-lib-builder/-/badges/release.svg)](https://gitlab.rlp.net/tron/tronmake-genome-lib-builder/-/releases)
[![Snakemake](https://img.shields.io/badge/snakemake-8.24.1-brightgreen.svg?style=flat)](https://snakemake.readthedocs.io)
[![pipeline status](https://gitlab.rlp.net/tron/tronmake-genome-lib-builder/badges/develop/pipeline.svg)](https://gitlab.rlp.net/tron/tronmake-genome-lib-builder/commits/master)

<!-- badges: end -->


The TronMake Genome Lib is a resource collection used by NGS analysis pipelines developed by the computational medicine group at [TRON](https://github.com/TRON-Bioinformatics). The TronMake Genome Lib Builder system is leveraged for preparing a reference genome and annotation set for use with SnakeMake and NextFlow based pipelines, including cancer-specific alternative splicing and somatic mutation discovery. The genome resource building process creates a unified 'TRON Genome library' based on GENCODE reference annotation and the GATK resource bundle (hg38). The workflow is implemented in SnakeMake (Mölder et al., 2021) for reproducible downloading and building of genome resource data. 

The following pipelines are compatible with the TRON Genome Lib:

- TronFlow pipelines
- splice2neo

Pre-built TRON Genome Libraries will be available for download for you to use and cite.

## Installation

Clone the repository:

```
git clone https://gitlab.rlp.net/tron/tronmake-genome-lib-builder.git
cd tronmake-genome-lib-builder
```

Create and activate the conda environment containing snakemake:

```
conda env create --name tronmake_genome --file environment.yaml
conda activate tronmake_genome
``` 

## Usage

The workflow consist of two stages. 

1. Pulling resource data from Gencode, UCSC and GATK.

2. Building genome indices

Both stages can be executed independently from each other. We recommend to build the genome library using the default resources pulled by `workflow/pull_resources.smk`. However, you can also download your own genome data and start with `workflow/build_indices.smk`.



## Authors & Acknowledgements 

The TronMake Genome Lib Builder was originally developed by Luis Kress and Johannes Hausmann at [TRON - Translational Oncology at the Medical Center of the Johannes Gutenberg University Mainz gGmbH (non-profit)](https://tron-mainz.de/).

Maintenance is now lead by Luis Kress and Johannes Hausmann. 

Main developers: 

- [Luis Kress](mailto:luis.kress@tron-mainz.de)
- [Johannes Hausmann](mailto:johannes.hausmann@tron-mainz.de)

Contributers:

- None / NA / NULL


## References

* Mölder F, Jablonski KP, Letcher B et al. Sustainable data analysis with Snakemake [version 1; peer review: 1 approved, 1 approved with reservations]. F1000Research 2021, 10:33 (https://doi.org/10.12688/f1000research.29032.1) 

