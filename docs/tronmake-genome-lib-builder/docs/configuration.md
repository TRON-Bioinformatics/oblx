# Configuration

The configuration file defines the parameters below. They are checked and
defaults set via the schema file at
[`workflow/schemas/config_validation.yaml`](/workflow/schemas/config_validation.yaml).

- `organism`: Takes `human` or `mouse`
- `release`: Gencode release version (starts with `M` for mouse)
- `genome_build`: Genome build version, has to match the `release` (currently
  supported: `GRCh38`, `GRCm39`, `GRCm38`)
- `gnomad_release`: Version of the gnomad release (suggested version: `4.1`)
- `intron_slop`: Number of intronic bases that should extend the exome
  definition `ref_exome.bed` (suggested: `20`)
- `exome_transcript_definition`: Define which GENCODE transcripts should be used
  to create the exome definition. The default is the `"basic"` tag. Please note
  that GENCODE basic definitions were deprecated in version 48 and replaced by
  the tag `"GENCODE_Primary"`. These are not the same sets of transcripts. For
  now, we recommend continuing to use basic transcripts.
- `star_sjdb_overhang`: `--sjdbOverhang` parameter for STAR index generation
  (should be read length - 1, in most cases `100` should be sufficient)
- `star_genome_sa_index_n_bases`: Defines the STAR parameter
  `genomeSAindexNbases` (default 14). The lower the value, the smaller the
  index. This can be useful, when creating test data for CI tests to keep the
  file small.
- `minimum_allele_frequency` (only required in human mode):
  `af_only_gnomad_hg38.vcf.gz` variants are filtered for population allele
  frequency > this cutoff (suggested: `0.001`)
- `gencode_url`: URL of GENCODE, where reference genome and annotation is
  downloaded from (default: "https://ftp.ebi.ac.uk/pub/databases/gencode")
- `ucsc_url` (only required in human mode): URL of UCSC FTP (default:
  "https://hgdownload.soe.ucsc.edu/gbdb/hg38")
- `ucsc_golden_path_url` (only required in human mode): URL of UCSC golden path
  (default: "https://hgdownload.soe.ucsc.edu/goldenPath")
- `gatk_url` (only required in human mode): URL of GATK resource bundle
  (default:
  "https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0")
- `gnomad_url` (only required in human mode): URL of GNOMAD (default:
  "https://storage.googleapis.com/gcp-public-data--gnomad/release")
- `chrom_filter`: List of chromosome names that should be contained in the
  `af_only_gnomad_hg38.vcf.gz` file

## Example Human

An example config file for human mode. For human data, unless you know for a
fact that it is needed, you may leave out filling out and specifying a config
file entirely.

```
organism: human
release: "46"
genome_build: GRCh38
gnomad_release: 4.1

# adds the defined slop to the generic exome definition (+/- intron_slop bp of intronic sequence)
intron_slop: 20

# Paramter for STAR index creation. Adapt to the read size if necessary
star_sjdb_overhang: 100
star_genome_sa_index_n_bases: 14

# Remove variants from gnomad VCF with poplutation allele frequency <= this cutoff
minimum_allele_frequency: 0.001

gencode_url: "https://ftp.ebi.ac.uk/pub/databases/gencode"
ucsc_url: "https://hgdownload.soe.ucsc.edu/gbdb/hg38"
ucsc_golden_path_url: "https://hgdownload.soe.ucsc.edu/goldenPath"
gatk_url: "https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0"
gnomad_url: "https://storage.googleapis.com/gcp-public-data--gnomad/release"

chrom_filter:
  - chr1
  - chr2
  - chr3
  - chr4
  - chr5
  - chr6
  - chr7
  - chr8
  - chr9
  - chr10
  - chr11
  - chr12
  - chr13
  - chr14
  - chr15
  - chr16
  - chr17
  - chr18
  - chr19
  - chr20
  - chr21
  - chr22
  - chrX
  - chrY
  - chrM
```

## Example Mouse

An example config file for mouse mode:

```
organism: mouse
release: "M36"
genome_build: GRCm39

# adds the defined slop to the generic exome definition (+/- intron_slop bp of intronic sequence)
intron_slop: 20

# Paramter for STAR index creation. Adapt to the read size if necessary
star_sjdb_overhang: 100
star_genome_sa_index_n_bases: 14

gencode_url: "https://ftp.ebi.ac.uk/pub/databases/gencode"

chrom_filter:
  - chr1
  - chr2
  - chr3
  - chr4
  - chr5
  - chr6
  - chr7
  - chr8
  - chr9
  - chr10
  - chr11
  - chr12
  - chr13
  - chr14
  - chr15
  - chr16
  - chr17
  - chr18
  - chr19
  - chrX
  - chrY
  - chrM
```
