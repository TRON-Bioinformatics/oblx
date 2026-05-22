# Build Indices

The build indices workflow generates indices for the following bioinformatics
tools. It builds the tool indices based on the previously
[pulled resources](pull_resources.md).

> Note: When using the generated indices, it is essential to ensure that the
> versions of the tools used in your analysis match the versions of the tools
> that were used to create the indices. Mismatched versions may lead to errors
> or inconsistent results. The versions for each tool can be found in the
> respective environment yaml file in `workflow/envs`.

- [STAR](https://github.com/alexdobin/STAR)
- [bwa](https://github.com/lh3/bwa)
- [bwa-mem2](https://github.com/bwa-mem2/bwa-mem2)
- [snpEff](https://github.com/pcingola/SnpEff)
- [salmon](https://combine-lab.github.io/salmon/)
- [kallisto](https://pachterlab.github.io/kallisto/)
- more will follow soon ...

## Input

The build indices workflow is run after [pull resources](pull_resources.md).
Therefore, the output of the pull resources workflow has to be present in the
directory, where the indices should be generated (snakemake command line
parameter `--directory` has to point to a directory that was created with the
pull_resources workflow).

## Usage

To run the build indices workflow run the following command.

```
snakemake --until build_indices \
    --directory </path/to/output/directory> \
    --software-deployment-method conda \
    --latency-wait 60 \
    [--configfile <path/to/config/file>] \
    [--conda-prefix </path/to/shared/conda/>] \
    [--profile </path/to/cluster/profile/>]
```

- `--directory`: Path to the directory that was created using
  [pull_resources](pull_resources.md) workflow
- `--software-deployment-method`: Has to be set to `conda`, as only conda is
  supported currently
- `--latency-wait`: Wait for e.g. 60 seconds for files to be created due to IO
  latency
- `--configfile` (optional): Defines e.g. the reference genome version that
  should be used, see [Configuration](configuration.md)
- `--conda-prefix` (optional): Specify a path where conda environments should be
  stored (to reduce redundancy)
- `--profile` (optional): Specify cluster profile to submit jobs e.g. to a HPC

## Output

The output of the build_indices workflow creates the `indices` directory next to
the `resources` directory, created by the [pull_resources](pull_resources.md)
workflow. The following directory structure is being created:

```
</path/to/output/directory>
├── indices
│   ├── bwa_mem
│   │   ├── ref_genome.fasta -> ../../resources/ref_genome_masked_final.fasta
│   │   ├── ref_genome.fasta.amb
│   │   ├── ref_genome.fasta.ann
│   │   ├── ref_genome.fasta.bwt
│   │   ├── ref_genome.fasta.fai
│   │   ├── ref_genome.fasta.pac
│   │   └── ref_genome.fasta.sa
│   ├── bwa_mem2
│   │   ├── ref_genome.fasta -> ../../resources/ref_genome_masked_final.fasta
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
│   │   │       ├── sequences.fa -> ../../../../resources/ref_genome_masked_final.fasta
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

### bwa_mem / bwa_mem2

The bwa_mem and bwa_mem2 directories contain the respective indices and a
symlink to the reference genome fasta file (if the genome is masked, in case of
human, this symlink points to the masked reference genome fasta).

### snpEff

This directory contains the resources required to run snpEff predictor.

**How to use the created resources to run snpEff?**

The file `snpeff.config` has to be passed to snpEff with the command line option
`-c` when running snpEff. Additionally, option `-nodownload` has to be set to
the value of the name of the subfolder in `results/indices/snpeff/data` (e.g.
`GRCh38.48`).

Example usage

```
snpEff \
    -stats <path_to_stats_outfile> \
    -csvStats <path_to_stats_outcsvfile> \
    -c <path_to_generated_snpeff_config> \
    -nodownload \
    <release> \
    <path_to_vcf_file>
```

### R

This directory contains GenomicFeatures respresentations of annotation data for
use with [splice2neo](https://github.com/TRON-Bioinformatics/splice2neo).

### Star

The STAR directory contains the STAR index. The path to the STAR directory has
to be set as `--genomeDir` parameter, when running STAR mapping.

### Salmon

Contains the [Salmon](https://salmon.readthedocs.io/en/latest/salmon.html)
index.

### Kallisto

Contains the [Kallisto](https://pachterlab.github.io/kallisto/) index.
