# Download Resources

The "Download Resources" subworkflow downloads resources required for common
bioinformatics analyses. The resources are downloaded from the providers listed
below. Each provider has its own license and citation requirements - please
review and acknowledge the original sources when using an OBLX generated
library.

> Note: OBLX downloads Twist Exome BED files from UCSC, these do not fall under
> an open source license, please check for your use case.

{{ read_table("resources/providers.tsv") }}

## Input

No input is required. However, the organism and releases of individual resources
can be specified in the [config file](configuration.md).

## Usage

To run the pull resources subworkflow, run the following command.

```
snakemake --until pull_resources \ 
    --directory </path/to/output/directory> \
    --software-deployment-method [conda|apptainer] \
    --latency-wait 60 \
    [--configfile <path/to/config/file>] \
    [--profile </path/to/cluster/profile/>]
```

- `--directory`: Directory to store the results of the workflow.
- `--software-deployment-method`: Either `conda` or `apptainer`. Container
  images for apptainer are configured in
  [`config/container_config.yaml`](https://github.com/TRON-Bioinformatics/oblx/blob/dev/config/container_config.yaml).
- `--latency-wait`: Wait for e.g. 60 seconds for files to be created due to IO
  latency
- `--configfile` (optional): Defines e.g. the reference genome version that
  should be used, see [Configuration](configuration.md)
- `--profile` (optional): Specify cluster profile to submit jobs e.g. to a HPC

## Output

The pull resources step gathers all files that are required for index generation
or that are directly used by downstream tools. An overview of all
downloaded/generated resources is given for
[human](#overview-of-downloaded-resources-in-human-mode)- and
[mouse](#overview-of-downloaded-resources-in-mouse-mode)-mode.

The workflow generates the following directory structure (in human mode):

```
</path/to/output/dir>/resources
├── exome_definition
│   ├── ref_cds.bed
│   ├── ref_exome.bed
│   ├── ref_exome.bed.gz
│   ├── ref_exome.bed.gz.tbi
│   ├── twist_comprehensive_exome.bed
│   ├── twist_core_exome.bed
│   ├── twist_exome2.bed
│   └── twist_refseq.bed
├── gatk_bundle
│   ├── 1000G_omni2.5.hg38.vcf.gz
│   ├── 1000G_omni2.5.hg38.vcf.gz.tbi
│   ├── 1000G_phase1.snps.high_confidence.hg38.vcf.gz
│   ├── 1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi
│   ├── hapmap_3.3.hg38.vcf.gz
│   ├── hapmap_3.3.hg38.vcf.gz.tbi
│   ├── Homo_sapiens_assembly38.dbsnp138.vcf.gz
│   ├── Homo_sapiens_assembly38.dbsnp138.vcf.gz.tbi
│   ├── Homo_sapiens_assembly38.known_indels.vcf.gz
│   ├── Homo_sapiens_assembly38.known_indels.vcf.gz.tbi
│   ├── Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
│   └── Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi
├── germline_variants
│   ├── gnomAD
│   │   └── {exomes,genomes}
│   │       ├── af_only_gnomad_hg38.vcf.gz
│   │       ├── af_only_gnomad_hg38.vcf.gz.tbi
│   │       ├── common_biallelic_chr1.vcf.gz
│   │       └── common_biallelic_chr1.vcf.gz.tbi
│   ├── dbSNP_151.vcf.gz
│   └── dbSNP_151.vcf.gz.tbi
├── mappability
│   ├── encode_exclusion.bed
│   ├── grcExclusions.bed
│   └── ucsc_problematic.bed
├── chromosome_sizes.txt
├── ref_annot.bed
├── ref_annot.gtf
├── ref_annot_gene2symbol.tsv
├── ref_annot_splice_sites.tsv
├── ref_annot_transcript2gene.tsv
├── ref_annot_metadata_SwissProt.tsv
├── ref_annot_metadata_TrEMBL.tsv
├── ref_genome_primary.fasta
├── ref_genome_grc_masked.fasta
├── ref_genome_masked_final.fasta
├── ref_genome.fasta
├── ref_genome.fasta.fai
├── ref_genome.dict
├── ref_transcripts.fasta
├── ref_genome_repeatmasker.bed
├── uniprot
│   └── uniprot_annotations.tsv
└── viruses
    └── tcga_virus_decoy.fasta
```

### Gencode reference files

The following files are downloaded directly from
[Gencode](https://www.gencodegenes.org/) (Mudge et al., 2025). In human mode,
problematic regions defined by [GRC](https://www.ncbi.nlm.nih.gov/grc) are hard
masked in the reference fasta while repetitive regions are not masked.

- `chromosome_sizes.txt`: Lengths of the chromosomes
- `ref_annot.gtf`: Comprehensive gene annotation based on primary assembly (PRI)
  (`gencode.v<release>.primary_assembly.annotation.gtf.gz`)
- `ref_annot.bed`: BED12 file of the transcripts (transformed from GTF file)
- `ref_genome.fasta`: Symlink to the primary assembly reference genome fasta.
  When pull_resources is run in human mode, the symlink points to the masked
  genome (masking is based on
  [`resources/mappability/grcExclusions.bed`](https://github.com/TRON-Bioinformatics/oblx/blob/dev/resources/mappability/grcExclusions.bed)
  which contains a set of regions that have been flagged by the
  [GRC](https://www.ncbi.nlm.nih.gov/grc) to contain false duplications or
  contamination sequences (Behera et al., 2022), downloaded from UCSC, see
  section [Mappability](#mappability)). Additionally in human mode,
  pseudoautosomal regions (defined in
  [`workflow/resources/GRCh38_pseudoautosomal_regions.bed`](https://github.com/TRON-Bioinformatics/oblx/blob/dev/workflow/resources/GRCh38_pseudoautosomal_regions.bed)
  from [Ensembl](https://www.ensembl.org/info/genome/genebuild/human_PARS.html))
  are hard masked. If pull_resources is run in mouse mode, the symlink points to
  the primary assembly (`ref_genome_primary.fasta`).
- `ref_genome_grc_masked.fasta` (Only given in human mode): Based on the primary
  assembly, problematic regions defined by GRC are hard masked (e.g. false
  duplications and contaminations,
  [see GIAB readme](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/references/README_GIAB_Mapping_References.md))
- `ref_genome_masked_final.fasta` (Only given in human mode): Based on
  `ref_genome_grc_masked.fasta` file, pseudoautosomal regions (defined in
  `workflow/resources/GRCh38_pseudoautosomal_regions.bed` from
  [Ensembl](https://www.ensembl.org/info/genome/genebuild/human_PARS.html)) are
  masked.
- `ref_annot_metadata_SwissProt.tsv`: UniProtKB/SwissProt entry associated to
  the transcript (from Ensembl xref pipeline
  `gencode.v<release>.metadata.SwissProt.gz`)
- `ref_annot_metadata_TrEMBL.tsv`: UniProtKB/TrEMBL entry associated to the
  transcript (from Ensembl xref pipeline
  `gencode.v<release>.metadata.TrEMBL.gz`)
- `ref_genome_primary.fasta`: Primary (PRI) assembly
  (`GRC<build>.primary_assembly.genome.fa.gz`)
- `ref_transcripts.fasta`: Transcript sequences
  (`gencode.v<release>.transcripts.fa.gz`)
- `ref_annot_transcript2gene.tsv`: Translation of transcript ID to gene ID
  (transformed from GTF file)
- `ref_annot_gene2symbol.tsv`: Translation of gene ID to gene symbol
  (`gencode.v<release>.metadata.HGNC.gz`)
- `ref_annot_splice_sites.tsv`: Splice sites of reference transcripts generated
  from the GTF (see
  [splice2neo](https://github.com/TRON-Bioinformatics/splice2neo))

### UCSC repeatmasker regions

The [RepeatMasker](https://www.repeatmasker.org/) annotated regions are
downloaded.

> Note: We do not mask the repetitive regions in the ref_genome.fasta file

- `ref_genome_repeatmasker.bed`: Repeat masker regions from
  [UCSC golden path](https://hgdownload.soe.ucsc.edu/downloads.html) translated
  into BED format.

### Exome definition

The exome definition directory contains exonic and CDS (coding sequence) BED
files. These files can be used e.g. to restrict specific variant callers (e.g.
Mutect2) to only consider the specified regions for variant calling. In human
and mouse mode the following files can be found in this directory:

- `ref_cds.bed`: The CDS (coding sequence) intervals derived from the annotation
  GTF. CDS regions are merged. Based on the
  [DeepVariant](https://github.com/google/deepvariant) RNA-seq variant calling
  tutorial.
- `ref_exome.bed`: The exonic intervals extended by `intron_slop` (default: 20)
  bases defined in the config file. The file was generated by selecting the
  exons from the annotation GTF with the tag defined in
  exome_transcript_definition.

In human mode, the
[Twist](https://www.twistbioscience.com/resources/data-files/twist-exome-20-bed-files)
exome bed files are additionally in this directory:

- `twist_refseq.bed`: Exome capture kit `Twist_Exome_RefSeq_targets_hg38.bb`
  downloaded from UCSC exomeProbesets transformed into bed file using
  `ucsc-bigbedtobed` version 469
- `twist_core_exome.bed`: Exome capture kit `Twist_Exome_Target_hg38.bb`
  downloaded from UCSC exomeProbesets transformed into bed file using
  `ucsc-bigbedtobed` version 469
- `twist_comprehensive_exome.bed`: Exome capture kit
  `Twist_ComprehensiveExome_targets_hg38.bb` downloaded from UCSC exomeProbesets
  transformed into bed file using `ucsc-bigbedtobed` version 469
- `twist_exome2.bed`: Exome capture kit `TwistExome21.bb` downloaded from UCSC
  exomeProbesets transformed into bed file using `ucsc-bigbedtobed` version 469

### GATK bundle

The GATK bundle is only available for human and thus only present in the output
when `pull_resources` is run in human mode. The URL to the GATK bundle for
download can be specified in the config file via the parameter `gatk_url` and is
by default the public Google cloud bucket:
[https://storage.googleapis.com/gcp-public-data--broad-references/hg38/v0](https://storage.googleapis.com/gcp-public-data--broad-references/hg38/v0).

The following files are downloaded:

- `1000G_omni2.5.hg38.vcf.gz`
- `1000G_phase1.snps.high_confidence.hg38.vcf.gz`
- `hapmap_3.3.hg38.vcf.gz`
- `Homo_sapiens_assembly38.dbsnp138.vcf.gz`
- `Homo_sapiens_assembly38.known_indels.vcf.gz`
- `Mills_and_1000G_gold_standard.indels.hg38.vcf.gz`

For all VCF files, the index is created using `tabix` v1.11.

### Germline variants

The germline variants are downloaded from
[gnomAD](https://gnomad.broadinstitute.org/) and processed and are only
available when `pull_resources` was run in human mode. The gnomAD version has to
be specified in the config file (see [Configuration](configuration.md)). Default
is v4.1 and tests were done for v4.1. For every file an index is created with
tabix v1.11. For gnomAD, the files `af_only_gnomad_hg38.vcf.gz` and
`common_biallelic_chr1.vcf.gz` are both generated for exomes and genomes and are
found in the respective subdirectory.

- `af_only_gnomad_hg38.vcf.gz`: gnomAD exome variants annotated only with
  population allele frequency for
  [Mutect2](https://gatk.broadinstitute.org/hc/en-us/articles/360037593851-Mutect2)
  - This file was created by downloading all chromosomes of gnomAD exome
    variants. Subsequently variants with a population allele frequency higher
    than `minimum_allele_frequency`, defined in the config (see
    [Configuration](configuration.md), default 0.001) are filtered for `PASS`.
    Finally all annotations are removed and only allele frequency is kept.
  - This file should be used as `--germline-resource` when running
    [Mutect2](https://gatk.broadinstitute.org/hc/en-us/articles/360037593851-Mutect2).
- `common_biallelic_chr1.vcf.gz`: Common germline variant sites VCF for
  [GetPileupSummaries](https://gatk.broadinstitute.org/hc/en-us/articles/360037593451-GetPileupSummaries)
  - This file was created from exonic variants on chromosome 1 from GNOMAD.
    These variants are filtered for `AF > 0.05`, `--max-alleles 2` and `PASS`
    (these filters are described in the Mutect2 best practices workflow where
    "[variants_for_contamination](https://github.com/broadinstitute/gatk/tree/master/scripts/mutect2_wdl)"
    is described)
- `dbSNP_151.vcf.gz`: dbSNP from
  [NCBI FTP server](https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/).
  Currently only version 151 is supported for human.
  - This file is downloaded from
    [NCBI FTP](https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/)
    and ENSEMBl chromosome names (without chr) are translated to Gencode
    chromosome names (with chr) using
    [chromosome mappings](https://github.com/dpryan79/ChromosomeMappings).
  - In mouse mode, the dbSNP file is named `dbSNP_mouse.vcf.gz` and is
    downloaded from [Ensembl FTP](https://ftp.ensembl.org/pub/) for the matching
    Ensembl version to the config specified GENCODE version. The chromosome
    names are adjusted to GENCODE convention via
    [https://github.com/dpryan79/ChromosomeMappings](https://github.com/dpryan79/ChromosomeMappings).

### Mappability

Mappability contains bed files with regions that are complicated to map with
short reads. The files are only downloaded when `pull_resources` is run in human
mode. These files are downloaded from
[UCSC](https://hgdownload.soe.ucsc.edu/gbdb/hg38/problematic). All files are
transformed to bed format using `ucsc-bigbedtobed` v469.

- `encode_exclusion.bed`: File `encBlacklist.bb` transformed to bed format.
- `grcExclusions.bed`: File `grcExclusions.bb` transformed to bed format.
- `ucsc_problematic.bed`: File `comments.bb` transformed to bed format.

### UniProt

The file `resources/uniprot/uniprot_annotations.tsv` contains data fetched from
https://rest.uniprot.org/uniprotkb/stream for the fields specified in
`workflow/scripts/programmatically_get_uniprot.py`. The table contains the
column `transcript_id` which contains the GENCODE identifiers retrieved from the
TrEMBL and SwissProt mappings fetched from GENCODE
(`resources/ref_annot_metadata_{TrEMBL,SwissProt}.tsv`).

### Viruses

Genome sequences of common cancer related viruses in fasta format that can be
used for contamination detection and profiling. The list of viruses
(`workflow/resources/tcga_viruses.tsv`) was downloaded from
[TCGA](https://gdc.cancer.gov/system/files/public/file/GRCh83.d1.vd1_virus_decoy.txt).
The viral decoy sequences listed in this file can be appended to the reference
genome (resources/ref_genome.fasta) to enable investigation of reads mapping to
viral sequences. If this is needed, all tool-specific indices that depend on the
reference FASTA (e.g., aligner index) must be rebuilt from the updated file.
Viral sequences are only downloaded in human mode.

### Overview of downloaded resources in human-mode

{{ read_table("resources/human_resources.tsv") }}

### Overview of downloaded resources in mouse-mode

{{ read_table("resources/mouse_resources.tsv") }}

## References

- Behera, S., LeFaive, J., Orchard, P., Mahmoud, M., Paulin, L. F., Farek, J.,
  Soto, D. C., Parker, S. C. J., Smith, A. V., Dennis, M. Y., Zook, J. M., &
  Sedlazeck, F. J. (2022). Fixing reference errors efficiently improves
  sequencing results. Genomics. https://doi.org/10.1101/2022.07.18.500506
- Casper, J., Speir, M. L., Raney, B. J., Perez, G., Nassar, L. R., Lee, C. M.,
  Hinrichs, A. S., Gonzalez, J. N., Fischer, C., Diekhans, M., Clawson, H.,
  Benet-Pages, A., Barber, G. P., Vaske, C. J., van Baren, M. J., Wang, K.,
  Rodriguez, Y. J. P., Jenkins-Kiefer, J. A., Chalamala, M., … Haeussler, M.
  (2026). The UCSC Genome Browser database: 2026 update. Nucleic Acids Research,
  54(D1), D1331–D1335.
  [https://doi.org/10.1093/nar/gkaf1250](https://doi.org/10.1093/nar/gkaf1250)
- Chen, S., Francioli, L. C., Goodrich, J. K., Collins, R. L., Kanai, M., Wang,
  Q., Alföldi, J., Watts, N. A., Vittal, C., Gauthier, L. D., Poterba, T.,
  Wilson, M. W., Tarasova, Y., Phu, W., Grant, R., Yohannes, M. T., Koenig, Z.,
  Farjoun, Y., Banks, E., … Karczewski, K. J. (2024). A genomic mutational
  constraint map using variation in 76,156 human genomes. Nature, 625(7993),
  92–100.
  [https://doi.org/10.1038/s41586-023-06045-0](https://doi.org/10.1038/s41586-023-06045-0)
- Karczewski, K. J., Francioli, L. C., Tiao, G., Cummings, B. B., Alföldi, J.,
  Wang, Q., Collins, R. L., Laricchia, K. M., Ganna, A., Birnbaum, D. P.,
  Gauthier, L. D., Brand, H., Solomonson, M., Watts, N. A., Rhodes, D.,
  Singer-Berk, M., England, E. M., Seaby, E. G., Kosmicki, J. A., … MacArthur,
  D. G. (2020). The mutational constraint spectrum quantified from variation in
  141,456 humans. Nature, 581(7809), 434–443.
  [https://doi.org/10.1038/s41586-020-2308-7](https://doi.org/10.1038/s41586-020-2308-7)
- Mudge, J. M., Carbonell-Sala, S., Diekhans, M., Martinez, J. G., Hunt, T.,
  Jungreis, I., Loveland, J. E., Arnan, C., Barnes, I., Bennett, R., Berry, A.,
  Bignell, A., Cerdán-Vélez, D., Cochran, K., Cortés, L. T., Davidson, C.,
  Donaldson, S., Dursun, C., Fatima, R., … Frankish, A. (2025). GENCODE 2025:
  Reference gene annotation for human and mouse. Nucleic Acids Research, 53(D1),
  D966–D975.
  [https://doi.org/10.1093/nar/gkae1078](https://doi.org/10.1093/nar/gkae1078)
- Phan, L., Zhang, H., Wang, Q., Villamarin, R., Hefferon, T., Ramanathan, A., &
  Kattman, B. (2025). The evolution of dbSNP: 25 years of impact in genomic
  research. Nucleic Acids Research, 53(D1), D925–D931.
  [https://doi.org/10.1093/nar/gkae977](https://doi.org/10.1093/nar/gkae977)
- The UniProt Consortium, Bateman, A., Martin, M.-J., Orchard, S., Magrane, M.,
  Adesina, A., Ahmad, S., Bowler-Barnett, E. H., Bye-A-Jee, H., Carpentier, D.,
  Denny, P., Fan, J., Garmiri, P., Gonzales, L. J. D. C., Hussein, A.,
  Ignatchenko, A., Insana, G., Ishtiaq, R., Joshi, V., … Zhang, J. (2025).
  UniProt: The Universal Protein Knowledgebase in 2025. Nucleic Acids Research,
  53(D1), D609–D617.
  [https://doi.org/10.1093/nar/gkae1010](https://doi.org/10.1093/nar/gkae1010)
- van der Auwera, G., & O’Connor, B. D. (2020). Genomics in the Cloud: Using
  Docker, GATK, and WDL in Terra. O’Reilly Media, Incorporated.
  [https://books.google.de/books?id=wwiCswEACAAJ](https://books.google.de/books?id=wwiCswEACAAJ)
