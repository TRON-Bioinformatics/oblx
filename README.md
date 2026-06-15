<p align="center">
    <img src="docs/oblx/docs/resources/logo.png" alt="logo" width="25%">
</p>

# OBLX: Omics builder for Bioinformatics resource Libraries and indeXes

<!-- badges: start -->

[![Snakemake](https://img.shields.io/badge/snakemake-9.20.0-brightgreen.svg?style=plastic)](https://snakemake.readthedocs.io)
[![pipeline status](https://github.com/TRON-Bioinformatics/oblx/actions/workflows/ci.yaml/badge.svg)](https://github.com/TRON-Bioinformatics/oblx/actions/workflows/ci.yaml)

<!-- badges: end -->

**Documentation**: https://tron-bioinformatics.github.io/oblx

<p align="center">
    <img src="docs/oblx/docs/resources/workflow_graph.png"
         alt="Brief visual description of OBLX, showing which resources are downloaded, which tool indices are created, for which purpose, and if that is for human usage only."
         width="50%">
</p>

______________________________________________________________________

**OBLX** (/ˌɒbl.ˈɛks/) is a pipeline which downloads reference genomes, genome
annotations and further resources, and generates from these the indexes required
for various bioinformatics tools and pipelines. The pipeline consists of two
independently executable stages:
[*Download Resources*](https://tron-bioinformatics.github.io/oblx/pull_resources/)
and
[*Build Indices*](https://tron-bioinformatics.github.io/oblx/build_indices/).
*Download Resources* retrieves the reference genome, genome annotation and other
resources and prepares the data for bioinformatics index generation. The
reference genome and genome annotation are downloaded from
[GENCODE](https://www.gencodegenes.org/); the preferred genome assembly version,
GENCODE release and organism can be specified via the
[config file](https://tron-bioinformatics.github.io/oblx/configuration/).
Additional resources from GATK, UCSC and gnomAD are retrieved (see
[*Download Resources*](https://tron-bioinformatics.github.io/oblx/pull_resources/)
for details). *Build Indices* then generates tool-specific indices. The
resulting genome library is consistent with respect to chromosome, transcript
and gene naming and supports an extensive set of bioinformatics tools, all
listed in
[Supported Tools](https://tron-bioinformatics.github.io/oblx/supported_tools/).
OBLX is implemented as a Snakemake pipeline (Mölder et al., 2021).

## Pre-built indices

Pre-built OBLX libraries for **human GRCh38 v49** and **mouse GRCm39 vM36** are
soon available for download via
[ftp://easyfuse.tron-mainz.de/oblx](ftp://easyfuse.tron-mainz.de/oblx).

```sh
# human
wget ftp://easyfuse.tron-mainz.de/oblx/v1.0.0/human/GRCh38_49

# mouse
wget ftp://easyfuse.tron-mainz.de/oblx/v1.0.0/mouse/GRCm39_M36
```

To verify the files run

```sh
sha256sum -c CHECKSUM_FILE
```

## Usage

To run OBLX, adapt and execute the following command:

```
snakemake -s workflow/Snakefile \
	--directory \
	[conda </path/to/output/directory >--software-deployment-method | apptainer] \
	--latency-wait 60 \
	[--configfile \
	[--profile <path/to/config/file >] </path/to/cluster/profile/ >]
```

## Input

OBLX does not require any user-provided input. You only specify the output
directory and, if non-default settings are desired, adapt the
[configuration](https://tron-bioinformatics.github.io/oblx/configuration/).

## Output

The output of the pipeline is written to the directory specified with
`--directory`. Descriptions of the downloaded genome resources are documented in
[*Download Resources*](https://tron-bioinformatics.github.io/oblx/pull_resources/);
descriptions of the generated indices are documented in
[*Build Indices*](https://tron-bioinformatics.github.io/oblx/build_indices/).

## Contribution

We welcome contributions! Please see
[CONTRIBUTING.md](CONTRIBUTING.md)
and
[developer_guide](https://tron-bioinformatics.github.io/oblx/developer_guide/)
for guidelines.

## About

OBLX was originally developed by Luis Kress and Johannes Hausmann at
[TRON - Translational Oncology at the Medical Center of the Johannes Gutenberg University Mainz gGmbH (non-profit)](https://tron-mainz.de/).

🛠️ Main developers:

- [Luis Kress](https://github.com/LKress)
- [Johannes Hausmann](https://github.com/johausmann)
- [Jonas Freimuth](https://github.com/jonasfreimuth)

✨ Contributors and code reviewers:

- [Jonas Ibn-Salem](https://github.com/ibn-salem)
- [Franziska Lang](https://github.com/franla23)

## References

- Mölder, F., Jablonski, K. P., Letcher, B., Hall, M. B., Van Dyken, P. C.,
  Tomkins-Tinch, C. H., Sochat, V., Forster, J., Vieira, F. G., Meesters, C.,
  Lee, S., Twardziok, S. O., Kanitz, A., VanCampen, J., Malladi, V., Wilm, A.,
  Holtgrewe, M., Rahmann, S., Nahnsen, S., & Köster, J. (2025). Sustainable data
  analysis with Snakemake. F1000Research, 10, 33.
  [https://doi.org/10.12688/f1000research.29032.3](https://doi.org/10.12688/f1000research.29032.3)
- Figure generated with [BioRender](https://app.biorender.com/) icons.
