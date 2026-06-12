# Supported bioinformatics pipelines

OBLX libraries can serve references for multiple bioinformatic workflows. Here,
we show two examples:

- [nf-core/sarek](https://github.com/nf-core/sarek)
- [tronflows](https://github.com/TRON-Bioinformatics/tronflow)

## nf-core/sarek

To run nf-core/sarek with an OBLX library, create a `nextflow.config` using an
utils script coming with OBLX that points Sarek to the required reference and
resource files in the OBLX library:

```
bash utils/write_sarek_config.sh </path/to/oblx/library> </path/to/output/nextflow.config>
```

And run nf-core/sarek with the previously generated nextflow.config file:

```
nextflow run nf-core/sarek -r 3.8.1 \
	-c </path/to/output/nextflow.config> \
	-profile singularity \
	--input <samplesheet.csv> \
	--tools mutect2,snpeff \
	--only_paired_variant_calling \
	--wes \
	--intervals </path/to/oblx/library>/resources/exome_definition/ref_exome.bed \
	--outdir </path/to/output/directory> 
```

## tronflows

Tronflows are a collection of standard bioinformatics workflows
([https://github.com/TRON-Bioinformatics/tronflow](https://github.com/TRON-Bioinformatics/tronflow)).

### tronflow-alignment

For
[tronflow-alignment](https://github.com/TRON-Bioinformatics/tronflow-alignment)
the reference has to be specified via the `--reference` flag.

Example for bwa-mem2:

```
nextflow run tron-bioinformatics/tronflow-alignment \
	-profile conda \
	--input_files $input \
	--output $output \
	--algorithm mem2 \
	--library paired \
	--reference </path/to/oblx/library>/indices/bwa_mem2/ref_genome.fasta
```

Example for STAR:

```
nextflow run tron-bioinformatics/tronflow-alignment \
	-profile conda \
	--input_files $input \
	--output $output \
	--algorithm star \
	--library paired \
	--reference </path/to/oblx/library>/indices/star/
```

### tronflow-bam-preprocessing

To run
[tronflow-bam-preprocessing](https://github.com/TRON-Bioinformatics/tronflow-bam-preprocessing)
with the OBLX Library, run the following.

```
nextflow run tron-bioinformatics/tronflow-bam-preprocessing
	-profile conda \
	--input_files $input \
	--reference </path/to/oblx/library>/resources/ref_genome.fasta \
	--dbsnp </path/to/oblx/library>/resources/germline_variants/dbSNP_151.vcf.gz \
	--known_indels1 </path/to/oblx/library>/resources/gatk_bundle/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
	--known_indels2 </path/to/oblx/library>/resources/gatk_bundle/Homo_sapiens_assembly38.known_indels.vcf.gz
	--intervals </path/to/oblx/library>/resources/exome_definition/ref_exome.bed
```

# Supported bioinformatics tools

The table below lists the bioinformatics tools that use files from the generated
OBLX Library and which file each tool requires.

> **Tool versions**: The pipeline does not pin downstream tool versions, but the
> indices are produced with specific tool versions. To guarantee compatibility,
> use the same tool versions for downstream analysis. The exact versions used to
> build each index are defined in the per-rule conda environments under
> [`workflow/envs/`](https://github.com/TRON-Bioinformatics/oblx/tree/dev/workflow/envs)
> and the corresponding apptainer/docker images in
> [`config/container_config.yaml`](https://github.com/TRON-Bioinformatics/oblx/blob/dev/config/container_config.yaml).

{{ read_table("resources/supported_tools.tsv") }}
