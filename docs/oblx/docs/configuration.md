# Configuration

The configuration file defines the values for the parameters below. Default
values are described in
[`workflow/schemas/config.schema.yaml`](https://github.com/TRON-Bioinformatics/oblx/blob/dev/workflow/schemas/config.schema.yaml).
If the user provides a config file, it is validated against this schema.

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
  "https://storage.googleapis.com/gcp-public-data--broad-references/hg38/v0")
- `gnomad_url` (only required in human mode): URL of GNOMAD (default:
  "https://storage.googleapis.com/gcp-public-data--gnomad/release")
- `chrom_filter`: List of chromosome names that should be contained in the
  `af_only_gnomad_hg38.vcf.gz` file

On top of that, we use the
[`config/container_config.yaml`](https://github.com/TRON-Bioinformatics/oblx/blob/dev/config/container_config.yaml)
file to specify URLs for the apptainer/docker containers `--sdm apptainer`.

## Example Human

An example config file to create a human OBLX Library. Unless required, it is
recommended to use the default configuration (see
[`workflow/schemas/config.schema.yaml`](https://github.com/TRON-Bioinformatics/oblx/blob/dev/workflow/schemas/config.schema.yaml)).

```
organism: human
release: "49"
genome_build: GRCh38
gnomad_release: 4.1

# adds the defined slop to the generic exome definition (+/- intron_slop bp of intronic sequence)
intron_slop: 20

# Parameter for STAR index creation. Adapt to the read size if necessary
star_sjdb_overhang: 100
star_genome_sa_index_n_bases: 14

# Remove variants from gnomad VCF with poplutation allele frequency <= this cutoff
minimum_allele_frequency: 0.001

gencode_url: "https://ftp.ebi.ac.uk/pub/databases/gencode"
ucsc_url: "https://hgdownload.soe.ucsc.edu/gbdb/hg38"
ucsc_golden_path_url: "https://hgdownload.soe.ucsc.edu/goldenPath"
gatk_url: "https://storage.googleapis.com/gcp-public-data--broad-references/hg38/v0"
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
```

## Example Mouse

An example config file for mouse mode:

```
organism: mouse
release: "M36"
genome_build: GRCm39

# adds the defined slop to the generic exome definition (+/- intron_slop bp of intronic sequence)
intron_slop: 20

# Parameter for STAR index creation. Adapt to the read size if necessary
star_sjdb_overhang: 100
star_genome_sa_index_n_bases: 14
```

## Support for non-GENCODE organisms

OBLX also supports generation of libraries for organisms that are not available
via GENCODE. Therefore the resources are pulled from
[Ensembl FTP](https://ftp.ensembl.org/pub/). To use data from Ensembl, specify
in the config file the following parameters:

- `organism`: The Ensembl organism name (begin with capital letter and "\_"
  separated, e.g. `Rattus_norvegicus` or `Capra_hircus`).
- `release`: Specify the Ensembl release in quotation marks (e.g., "116").
- `genome_build`: The genome build (e.g., "GRCr8", "GRCh38", ...).
- `chromosome_mapping_file`: Path to a tab separated file mapping the Ensembl
  chromosome names to the UCSC chromosome naming convention. **Note**: This has
  to be provided as an absolute path (e.g. `/path/to/your/chrom_mapping.txt`).
- `exome_transcript_definition`: Transcripts to filter for when generating the
  `resources/exome_definition/ref_exome.bed` file (default: `basic`).
- `ensembl_mysql_build`: Build for the organism in the Ensembl mysql FTP (see
  [https://ftp.ensembl.org/pub/release-116/mysql/](https://ftp.ensembl.org/pub/release-116/mysql/);
  e.g., rattus_norvegicus_core_116\_**1**/ would be "1").
- `chrom_filter`: Chromosomes to download and filter VCF. You can check
  [https://ftp.ensembl.org/pub/release-116/fasta/rattus_norvegicus/dna/](https://ftp.ensembl.org/pub/release-116/fasta/rattus_norvegicus/dna/)
  which chromosomes are available for the specified organism.

```
organism: Rattus_norvegicus
release: "116"
genome_build: GRCr8
chromosome_mapping_file: /path/to/your/chromosome/mapping/file/rat_map.txt
exome_transcript_definition: "gencode_basic"
ensembl_mysql_build: "1"
chrom_filter:
  - "1"
  - "2"
  - "3"
  - "4"
  - "5"
  - "6"
  - "7"
  - "8"
  - "9"
  - "10"
  - "11"
  - "12"
  - "13"
  - "14"
  - "15"
  - "16"
  - "17"
  - "18"
  - "19"
  - "20"
  - "MT"
  - "X"
  - "Y"
```

Example of the `chromosome_mapping_file` for the above config file:

```
1	chr1
10	chr10
11	chr11
12	chr12
13	chr13
14	chr14
15	chr15
16	chr16
17	chr17
18	chr18
19	chr19
2	chr2
20	chr20
3	chr3
4	chr4
5	chr5
6	chr6
7	chr7
8	chr8
9	chr9
MT	chrM
X	chrX
Y	chrY
```
