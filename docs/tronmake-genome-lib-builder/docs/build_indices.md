# Build Indices

The build indices workflow generates indices for the following bioinformatics tools:

* [STAR](https://github.com/alexdobin/STAR)
* [bwa-mem2](https://github.com/bwa-mem2/bwa-mem2)
* [snpEff](https://github.com/pcingola/SnpEff)
* more will follow soon ...

It builds the indices based on the previously [pulled resources](pull_resources.md).

## Input

The build indices workflow is run after [pull resources](pull_resources.md). Therefore,
the output of the pull resources workflow has to be present in the directory, where the
indices should be generated.

## Usage

```
snakemake -s workflow/build_indices.smk \
    --directory </path/to/output/directory> \
    --software-deployment-method conda \
    --latency-wait 60 \
    [--conda-prefix </path/to/shared/conda/>] \
    [--profile </path/to/cluster/profile/>]
```

TODO: describe parameters

## Output

The workflow generates the following directory structure:

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
│   ├── snpeff
│   │   ├── data
│   │   │   └── GRCh38.46
│   │   │       ├── genes.gtf -> ../../../../resources/ref_annot.gtf
│   │   │       ├── sequence.10.bin
│   │   │       ├── sequence.11.bin
│   │   │       ├── sequence.12.bin
│   │   │       ├── sequence.13.bin
│   │   │       ├── sequence.14.bin
│   │   │       ├── sequence.15.bin
│   │   │       ├── sequence.16.bin
│   │   │       ├── sequence.17.bin
│   │   │       ├── sequence.18.bin
│   │   │       ├── sequence.19.bin
│   │   │       ├── sequence.1.bin
│   │   │       ├── sequence.20.bin
│   │   │       ├── sequence.21.bin
│   │   │       ├── sequence.22.bin
│   │   │       ├── sequence.2.bin
│   │   │       ├── sequence.3.bin
│   │   │       ├── sequence.4.bin
│   │   │       ├── sequence.5.bin
│   │   │       ├── sequence.6.bin
│   │   │       ├── sequence.7.bin
│   │   │       ├── sequence.8.bin
│   │   │       ├── sequence.9.bin
│   │   │       ├── sequence.bin
│   │   │       ├── sequences.fa -> ../../../../resources/ref_genome_grc_masked.fasta
│   │   │       ├── sequence.X.bin
│   │   │       ├── sequence.Y.bin
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
    ├── chromosome_sizes.txt
    ├── exome_definition
    │   ├── ref_exome.bed
    │   ├── twist_comprehensive_exome.bed
    │   ├── twist_core_exome.bed
    │   ├── twist_exome2.bed
    │   └── twist_refseq.bed
    ├── gatk_bundle
    │   ├── Homo_sapiens_assembly38.dbsnp138.vcf.gz
    │   ├── Homo_sapiens_assembly38.dbsnp138.vcf.gz.tbi
    │   ├── Homo_sapiens_assembly38.known_indels.vcf.gz
    │   ├── Homo_sapiens_assembly38.known_indels.vcf.gz.tbi
    │   ├── Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
    │   └── Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi
    ├── germline_variants
    │   ├── af_only_gnomad_hg38.vcf.gz
    │   ├── af_only_gnomad_hg38.vcf.gz.tbi
    │   ├── common_biallelic_chr1.vcf.gz
    │   ├── common_biallelic_chr1.vcf.gz.tbi
    │   ├── dbSNP_151.vcf.gz
    │   └── dbSNP_151.vcf.gz.tbi
    ├── mappability
    │   ├── encode_exclusion.bed
    │   ├── grcExclusions.bed
    │   └── ucsc_problematic.bed
    ├── ref_annot.bed
    ├── ref_annot.gtf
    ├── ref_annot_metadata_SwissProt.tsv
    ├── ref_annot_metadata_TrEMBL.tsv
    ├── ref_genome.fasta -> ref_genome_grc_masked.fasta
    ├── ref_genome_grc_masked.fasta
    ├── ref_genome_primary.fasta
    ├── ref_genome_repeatmasker.bed
    ├── ref_transcripts.fasta
    ├── ucsc_repeatmasker_dump.txt.gz
    └── viruses
        └── tcga_virus_decoy.fasta

```