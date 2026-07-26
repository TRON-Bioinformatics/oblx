# Implementation Plan: T2T (CHM13v2.0) Support for OBLX

This document outlines the necessary technical changes to integrate
Telomere-to-Telomere (T2T) assembly support into the OBLX resource acquisition
and index build pipeline.

## 1. Configuration & Schema

To enable T2T as a valid target, the following configuration updates are
required:

- **Schema Update**: Add `T2T` to the `genome_build` enum in
  `workflow/schemas/config.schema.yaml`.
- **Constants**: Define T2T-specific resource URLs (S3 and Ensembl HPRC) within
  the workflow or as config defaults.

## 2. Resource Acquisition Pipeline (`workflow/rules/pull_resources.smk`)

### Architectural Approach: Rule Inheritance

To keep the codebase clean and DRY, we will utilize Snakemake's
`use rule ... as ... with:` syntax (available in v6.0+). This allows us to
inherit the shell execution logic from existing HG38 rules while overriding only
the inputs (URLs) and outputs (filenames) for T2T.

### A. Reference Genome & Annotation

| Status        | Rule(s)                                       | Change Description                                                                                | Implementation Detail / URLs                                                                                                                                                                                                                                                                           |
| :------------ | :-------------------------------------------- | :------------------------------------------------------------------------------------------------ | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **New**       | `download_t2t_genome`                         | Implement S3 download of reference genome.                                                        | Use `use rule download_gencode_data as ... with:`. <br> URL: `https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/analysis_set/chm13v2.0_maskedY_rCRS.fa.gz`                                                                                                                     |
| **New**       | `download_t2t_annotation`                     | Implement Ensembl FTP download for HPRC GENCODEv38.                                               | Use `use rule download_gencode_data as ... with:`. <br> GTF: `https://ftp.ebi.ac.uk/pub/ensemblorganisms/Homo_sapiens/GCA_009914755.4/ensembl/geneset/2022_07/genes.gtf.gz` <br> GFF3: `https://ftp.ebi.ac.uk/pub/ensemblorganisms/Homo_sapiens/GCA_009914755.4/ensembl/geneset/2022_07/genes.gff3.gz` |
| **New**       | `synthesize_t2t_transcriptome`                | Download cDNA -> use `gffread` to include ncRNA.                                                  | New distinct rule. <br> URL: `https://ftp.ebi.ac.uk/pub/ensemblorganisms/Homo_sapiens/GCA_009914755.4/ensembl/geneset/2022_07/cdna.fa.gz`                                                                                                                                                              |
| **Redefined** | `download_gencode_data`, `download_ucsc_data` | Parameterize or branch logic to avoid HG38-specific hardcoded paths when `genome_build == 'T2T'`. | Refactor as base rules using config variables.                                                                                                                                                                                                                                                         |

### B. Variant Databases

| Status        | Rule(s)                                                                      | Change Description                                                                                  | Implementation Detail / URLs                                                                                                                                                                                                                                                                                                                                                           |
| :------------ | :--------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **New**       | `download_t2t_gnomad`                                                        | Implement download of trimmed liftover VCFs from Ensembl.                                           | New rule. <br> Exomes: `https://ftp.ebi.ac.uk/pub/ensemblorganisms/Homo_sapiens/GCA_009914755.4/vep/genome/vep_gnomad_exomes/gnomad.exomes.v4.1.sites.GCA_009914755.4.trimmed_liftover.vcf.gz` <br> Genomes: `https://ftp.ebi.ac.uk/pub/ensemblorganisms/Homo_sapiens/GCA_009914755.4/vep/genome/vep_gnomad_genomes/gnomad.genomes.v4.1.sites.GCA_009914755.4.trimmed_liftover.vcf.gz` |
| **New**       | `download_t2t_dbsnp`                                                         | Implement S3 download of release 155 liftovered VCF.                                                | Use `use rule download_dbsnp_human as ... with:`. <br> URL: `https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/annotation/liftover/chm13v2.0_dbSNPv155.vcf.gz`                                                                                                                                                                                                 |
| **Redefined** | `download_gnomad`, `af_only_gnomad`, `download_dbsnp_human`, `prepare_dbsnp` | These rules are specific to HG38/GRCh38; they must be bypassed or replaced by the T2T counterparts. | Use a conditional switch in the target rule selection logic.                                                                                                                                                                                                                                                                                                                           |

### C. Masking & Mappability

| Status        | Rule(s)                            | Change Description                                              | Implementation Detail / URLs                                                                                                                                                                                                                                                             |
| :------------ | :--------------------------------- | :-------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **New**       | `download_t2t_repeatmasker`        | Implement download of RepeatMasker BED or BigBed.               | Use `use rule download_repeat_masker as ... with:`. <br> S3: `https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/annotation/chm13v2.0_RepeatMasker_4.1.2p1.2022Apr14.bed` <br> UCSC: `https://hgdownload.soe.ucsc.edu/gbdb/hs1/t2tRepeatMasker/chm13v2.0_rmsk.bb` |
| **New**       | `download_t2t_accessibility_mask`  | Implement S3 download of combined accessibility mask.           | New rule. <br> URL: `https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/annotation/accessibility/hs1.combined_mask.bed`                                                                                                                                           |
| **New**       | `download_t2t_problematic_regions` | Download GIAB BigBed -> convert to BED via `bigBedToBed`.       | Use `use rule download_ucsc_data as ... with:`. <br> URL: `https://hgdownload.soe.ucsc.edu/gbdb/hs1/problematic/GIAB/alldifficultregions.bb`                                                                                                                                             |
| **Redefined** | `download_repeat_masker`           | Branch logic to support T2T sources instead of HG38-only paths. | Base rule -> inherited T2T rule.                                                                                                                                                                                                                                                         |

## 3. Liftover Pipeline (GRCh38 -> T2T)

Since native T2T resources for some tools are unavailable, a new sequence of
rules is required:

1. **New Rule**: `download_t2t_chain` -> Fetch `grch38-chm13v2.chain`.
   - URL:
     `https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/chain/v1_nflo/grch38-chm13v2.chain`
1. **Rule Dependency**: Ensure HG38 `download_gatk_bundle` and
   `download_exome_probesets` can run independently to provide source files.
1. **New Rule**: `liftover_gatk_resources` -> Execute `CrossMap vcf` for Mills,
   1000G, and HapMap.
1. **New Rule**: `liftover_exome_probesets` -> Execute `CrossMap bed` for Twist
   capture kit BEDs.

## 4. Genome Masking & Processing (`workflow/rules/genome_masking.smk`)

| Status       | Rule(s)                                            | Change Description                                                                                                                     |
| :----------- | :------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------- |
| **Bypassed** | `mask_GRC_assembly_errors`, `mask_pseudoautosomal` | These are HG38-specific. Implement logic to skip these when using T2T, as the reference is pre-masked and uses a different mask model. |

## 5. Generic Rules (Unmodified)

The following rule sets remain unmodified as they operate on generic inputs
provided by the path resolver:

- **Index Building**: `bwa_mem_index`
  ([`../workflow/rules/bwa-mem.smk`](../workflow/rules/bwa-mem.smk)), `star`
  index rules, etc. These simply take the FASTA output from the pull phase.
- **Interval Generation**: `gencode_exome_bed`, `gencode_cds_bed`
  ([`../workflow/rules/intervals.smk`](../workflow/rules/intervals.smk)). These
  process GTF -> BED and are assembly-agnostic provided a valid GTF is input.
- **Index Helpers**: `chrom_sizes`
  ([`../workflow/rules/intervals.smk`](../workflow/rules/intervals.smk)) as it
  relies on the `.fai` file.

## 6. Documentation Updates

To reflect T2T support, the following documentation changes are required:

### A. [`../docs/oblx/docs/configuration.md`](../docs/oblx/docs/configuration.md)

- **Parameter List**: Update `genome_build` to include `T2T`.
- **Example Section**: Add a new "Example T2T" configuration block showing the
  use of `genome_build: T2T`.

### B. [`../docs/oblx/docs/pull_resources.md`](../docs/oblx/docs/pull_resources.md)

- **Output Structure**: Update the directory tree to show that filenames may
  differ for T2T or add a dedicated "T2T Output" section detailing the specific
  files produced for this build.
- **Reference Files Section**: Clarify that `ref_genome` for T2T is pre-masked
  (CHM13v2.0 maskedY) and does not undergo the HG38 GRC-masking process
  described in the current doc.
- **GATK & Exome Sections**: Add a note explaining that resources for T2T are
  generated via liftover from GRCh38 using `CrossMap`.

### C. [`../docs/oblx/docs/resources/human_resources.tsv`](../docs/oblx/docs/resources/human_resources.tsv)

- **Resource Table**: Add new entries for the T2T reference genome, annotations,
  and liftovered VCFs to ensure traceability.

## 7. Integration & Testing

- **Path Mapping**: Update `get_pull_resources_output` in
  [`../workflow/Snakefile`](../workflow/Snakefile) to conditionally map T2T
  paths vs standard GRChx paths.
- **Validation**: Perform a dry-run (`snakemake -n`) with a custom config
  specifying `genome_build: T2T` to verify the full dependency chain (HG38
  Source -> CrossMap -> T2T Reference).
