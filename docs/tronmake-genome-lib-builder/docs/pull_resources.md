# Pull Resources

The pull resources workflow downloads resources required for genome analysis.

## Input

No input is required. However, the organism and release on which the downloaded
resources should be based on has to be specified in the config file.

TODO: describe config file setup -> maybe it is helpful to specify the organism release and genome build via the command line in Usage

## Usage

```
snakemake -s workflow/pull_resources.smk \
    --directory </path/to/output/directory> \
    --software-deployment-method conda \
    --latency-wait 60 \
    [--conda-prefix </path/to/shared/conda/>] \
    [--profile </path/to/cluster/profile/>]
```

TODO: describe parameters

## Output

The pull resources step gathers all files that are required for index generation
or that are directly used by downstream tools.

The workflow generates the following directory structure:

```
</path/to/output/dir>/resources
├── exome_definition
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
├── ref_genome_primary.fasta
├── ref_transcripts.fasta
├── ucsc_repeatmasker_dump.txt.gz
└── viruses
    └── tcga_virus_decoy.fasta
```

TODO: describe files
