# Build Indices

The build indices workflow generates indices for the following bioinformatics tools:

* [STAR](https://github.com/alexdobin/STAR)
* [bwa-mem2](https://github.com/bwa-mem2/bwa-mem2)
* [snpEff](https://github.com/pcingola/SnpEff)
* [salmon](https://combine-lab.github.io/salmon/)
* [kallisto](https://pachterlab.github.io/kallisto/)
* more will follow soon ...

It builds the indices based on the previously [pulled resources](pull_resources.md).

## Input

The build indices workflow is run after [pull resources](pull_resources.md). Therefore,
the output of the pull resources workflow has to be present in the directory, where the
indices should be generated (snakemake command line parameter `--directory` has to point
to a directory that was created with the pull_resources workflow).

## Usage

To run the build indices workflow run the following command.

```
snakemake -s workflow/build_indices.smk \
    --directory </path/to/output/directory> \
    --software-deployment-method conda \
    --latency-wait 60 \
    [--configfile <path/to/config/file>] \
    [--conda-prefix </path/to/shared/conda/>] \
    [--profile </path/to/cluster/profile/>]
```

* `--directory`: Path to the directory that was created using pull_resources workflow
* `--software-deployment-method`: Has to be set to `conda`, as only conda is supported currently
* `--latency-wait`: Wait for e.g. 60 seconds for files to be created due to IO latency
* `--configfile` (optional): Defines e.g. the reference genome version that should be used, see [Configuration](configuration.md) (default: `config/default.yaml`)
* `--conda-prefix` (optional): Specify a path where conda environments should be stored (to reduce redundancy)
* `--profile` (optional): Specify cluster profile to submit jobs e.g. to a HPC 

## Output

The output of the build_indices workflow creates the `indices` directory
next to the `resources` directory, created by the pull_resources workflow.
The following directory structure is being created:

```
</path/to/output/directory>
├── indices
│   ├── bwa
│   │   ├── ref_genome.fasta -> ../../resources/ref_genome_grc_masked.fasta
│   │   ├── ref_genome.fasta.0123
│   │   ├── ref_genome.fasta.amb
│   │   ├── ref_genome.fasta.ann
│   │   ├── ref_genome.fasta.bwt.2bit.64
│   │   ├── ref_genome.fasta.fai
│   │   └── ref_genome.fasta.pac
│   ├── kallisto
│   │   ├── ref_cdna.fa
│   │   ├── ref_transcript.idx
│   │   └── ref_transcript_to_gene.tsv
|   ├── R
│   │   ├── ref_annot_txdb.sqlite
│   │   ├── ref_genome.2bit
│   │   ├── ref_transcripts.Rds
│   │   ├── ref_transcript_ranges.Rds'
│   │   └── ref_cds.Rds
│   ├── salmon
│   │   ├── decoys.txt
│   │   ├── gentrome.fasta
│   │   └── transcriptome_index
│   ├── snpeff
│   │   ├── data
│   │   │   └── GRCh38.46
│   │   │       ├── genes.gtf -> ../../../../resources/ref_annot.gtf
│   │   │       ├── sequences.fa -> ../../../../resources/ref_genome_grc_masked.fasta
│   │   │       └── snpEffectPredictor.bin
│   │   └── snpeff.config
│   └── star
│       ├── chrLength.txt
│       ├── chrNameLength.txt
│       ├── chrName.txt
│       ├── chrStart.txt
│       ├── exonGeTrInfo.tab
│       ├── exonInfo.tab
│       ├── geneInfo.tab
│       ├── Genome
│       ├── genomeParameters.txt
│       ├── Log.out
│       ├── SA
│       ├── SAindex
│       ├── sjdbInfo.txt
│       ├── sjdbList.fromGTF.out.tab
│       ├── sjdbList.out.tab
│       └── transcriptInfo.tab
└── resources
```

### bwa

Current bwa-mem2 version: **v2.2.1**

The bwa directory contains the bwa-mem2 index and a symlink to the reference genome 
fasta file (if the genome is masked, in case of human, this symlink points to
the masked reference genome fasta).

### snpEff

This directory contains the resources required to run snpEff predictor. 

Current snpEff version: **v5.2**

**How to use the created resources to run snpEff?**

The file `snpeff.config` has to be passed to snpEff with the command line option `-c` when
running snpEff. Additionally, option `-nodownload` has to be set to the value of
the name of the subfolder in `results/indices/snpeff/data` (e.g. `GRCh38.48`).

### R

This directory contains GenomicFeatures respresentations of annotation data for use 
with [splice2neo](https://github.com/TRON-Bioinformatics/splice2neo).

### star

Current STAR version: **v2.7.11a**

The STAR directory contains the STAR index. The path to the STAR directory has 
to be set as `--genomeDir` parameter, when running STAR mapping.


### Salmon

Contains the [Salmon](https://salmon.readthedocs.io/en/latest/salmon.html) 
index for [mapping based mode of Salmon](https://salmon.readthedocs.io/en/latest/salmon.html#preparing-transcriptome-indices-mapping-based-mode).

### Kallisto

Contains the [Kallisto](https://pachterlab.github.io/kallisto/) index.
