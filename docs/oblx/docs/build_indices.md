# Build Indices

The build indices subworkflow generates indices for the following bioinformatics
tools. It builds the tool indices based on the previously
[pulled resources](pull_resources.md). An extensive list of all supported
bioinformatics tools can be found [here](supported_tools.md).

> Note: When using the generated indices, it is essential to ensure that the
> versions of the tools used in your analysis match the versions of the tools
> that were used to create the indices. Mismatched versions may lead to errors
> or inconsistent results. The versions for each tool can be found in the
> respective environment yaml file in `workflow/envs`.

- [STAR](https://github.com/alexdobin/STAR)
- [bwa-mem](https://github.com/lh3/bwa)
- [bwa-mem2](https://github.com/bwa-mem2/bwa-mem2)
- [snpEff](https://github.com/pcingola/SnpEff)
- [salmon](https://combine-lab.github.io/salmon/)
- [kallisto](https://pachterlab.github.io/kallisto/)
- [bowtie2](https://github.com/benlangmead/bowtie2)
- [hisat2](https://github.com/daehwankimlab/hisat2)

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
    --software-deployment-method [conda|apptainer] \
    --latency-wait 60 \
    [--configfile <path/to/config/file>] \
    [--profile </path/to/cluster/profile/>]
```

- `--directory`: Specifies the directory where the results of the workflow
  should be stored.
- `--software-deployment-method`: Either `conda` or `apptainer`. Container
  images for apptainer are configured in
  [`config/container_config.yaml`](configuration.md).
- `--latency-wait`: Wait for e.g. 60 seconds for files to be created due to IO
  latency
- `--configfile` (optional): Defines e.g. the reference genome version that
  should be used, see [Configuration](configuration.md)
- `--profile` (optional): Specify cluster profile to submit jobs e.g. to a HPC

## Output

The output of the build_indices workflow creates the `indices` directory next to
the `resources` directory, created by the [pull_resources](pull_resources.md)
workflow. The following directory structure is being created:

```
</path/to/output/directory>
├── indices
│   ├── bowtie2
│   │   ├── genome.1.bt2
│   │   ├── genome.2.bt2
│   │   ├── genome.3.bt2
│   │   ├── genome.4.bt2
│   │   ├── genome.rev.1.bt2
│   │   └── genome.rev.2.bt2
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
│   ├── hisat2
│   │   ├── genome.1.ht2
│   │   ├── genome.2.ht2
│   │   ├── genome.3.ht2
│   │   ├── genome.4.ht2
│   │   ├── genome.5.ht2
│   │   ├── genome.6.ht2
│   │   ├── genome.7.ht2
│   │   ├── genome.8.ht2
│   │   ├── genome.exon
│   │   ├── genome.haplotype
│   │   ├── genome.snp
│   │   └── genome.ss
│   ├── kallisto
│   │   ├── ref_cdna.fa
│   │   ├── ref_transcript.idx
│   │   └── ref_transcript_to_gene.tsv
│   ├── R
│   │   ├── ref_annot_txdb.sqlite
│   │   ├── ref_cds.Rds
│   │   ├── ref_genome.2bit
│   │   ├── ref_transcript_ranges.Rds
│   │   └── ref_transcripts.Rds
│   ├── salmon
│   │   ├── decoys.txt
│   │   ├── gentrome.fasta
│   │   ├── transcriptome_index
│   │   │   ├── complete_ref_lens.bin
│   │   │   └── ...
│   │   └── requant_index
│   │       └── transcripts.fa
│   ├── snpeff
│   │   ├── data
│   │   │   └── GRCh38.<release>
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

### bowtie2

Contains the index for bowtie2 (Langmead, B., & Salzberg, S. L., 2012) (based on
the masked reference genome in human mode, see
[Gencode reference files](pull_resources.md#gencode-reference-files)).

### hisat2

Contains the index for hisat2 (Kim et al., 2019) (based on the masked reference
genome in human mode, see
[Gencode reference files](pull_resources.md#gencode-reference-files)). The index
was generated with the respective dbSNP VCF file (see
[Germline Variants](pull_resources.md#germline-variants)). Due to the large
amount of SNPs available for mouse, we currently do not provide a hisat2 index
for this organism (See
[#174](https://github.com/TRON-Private/tronmake-genome-lib-builder/issues/174)
for more on this).

### bwa_mem / bwa_mem2

The bwa_mem (Li, H., & Durbin, R., 2009) and bwa_mem2 (Vasimuddin et al., 2019)
directories contain the respective indices and a symlink to the reference genome
fasta file (if the genome is masked, in case of human, this symlink points to
the masked reference genome fasta, see
[Gencode reference files](pull_resources.md#gencode-reference-files)).

### snpEff

This directory contains the resources required to run snpEff (Cingolani, et al.,
2012\) predictor.

**How to use the created resources to run snpEff?**

The file `snpeff.config` has to be passed to snpEff with the command line option
`-c` when running snpEff. Additionally, the database name matching the subfolder
under `indices/snpeff/data` (e.g. `GRCh38.49`) must be passed as a positional
argument, and `-nodownload` must be set so snpEff does not try to fetch the
database from the internet.

Example usage

```
snpEff \
    -stats <path_to_stats_outfile> \
    -csvStats <path_to_stats_outcsvfile> \
    -c <path_to_generated_snpeff_config> \
    -nodownload \
    <genome_build>.<release> \
    <path_to_vcf_file>
```

### R

This directory contains GenomicFeatures representations of annotation data for
use with [splice2neo](https://github.com/TRON-Bioinformatics/splice2neo) (Lang
et al., 2024).

### Star

The STAR (Dobin et al., 2013) directory contains the STAR index. The path to the
STAR directory has to be set as `--genomeDir` parameter, when running STAR
mapping.

### Salmon

Contains the [Salmon](https://salmon.readthedocs.io/en/latest/salmon.html)
(Patro et al., 2017) index. The `transcriptome_index` subdirectory holds the
main gentrome-based index for quantification. The `requant_index/transcripts.fa`
file is a transcript-only FASTA derived from the annotation and reference genome
via `gffread`, intended for re-quantification workflows that require an
annotation-consistent transcript sequence.

### Kallisto

Contains the [Kallisto](https://pachterlab.github.io/kallisto/) (Bray et al.,
2016\) index.

## References

- Cingolani, P., Platts, A., Wang, L. L., Coon, M., Nguyen, T., Wang, L., Land,
  S. J., Lu, X., & Ruden, D. M. (2012). A program for annotating and predicting
  the effects of single nucleotide polymorphisms, SnpEff: SNPs in the genome of
  Drosophila melanogaster strain w1118; iso-2; iso-3. Fly, 6(2), 80–92.
  [https://doi.org/10.4161/fly.19695](https://doi.org/10.4161/fly.19695)
- Dobin, A., Davis, C. A., Schlesinger, F., Drenkow, J., Zaleski, C., Jha, S.,
  Batut, P., Chaisson, M., & Gingeras, T. R. (2013). STAR: Ultrafast universal
  RNA-seq aligner. Bioinformatics, 29(1), 15–21.
  [https://doi.org/10.1093/bioinformatics/bts635](https://doi.org/10.1093/bioinformatics/bts635)
- Kim, D., Paggi, J. M., Park, C., Bennett, C., & Salzberg, S. L. (2019).
  Graph-based genome alignment and genotyping with HISAT2 and HISAT-genotype.
  Nature Biotechnology, 37(8), 907–915.
  [https://doi.org/10.1038/s41587-019-0201-4](https://doi.org/10.1038/s41587-019-0201-4)
- Langmead, B., & Salzberg, S. L. (2012). Fast gapped-read alignment with Bowtie
  2\. Nature Methods, 9(4), 357–359.
  [https://doi.org/10.1038/nmeth.1923](https://doi.org/10.1038/nmeth.1923)
- Lang, F., Sorn, P., Suchan, M., Henrich, A., Albrecht, C., Köhl, N., Beicht,
  A., Riesgo-Ferreiro, P., Holtsträter, C., Schrörs, B., Weber, D., Löwer, M.,
  Sahin, U., & Ibn-Salem, J. (2024). Prediction of tumor-specific splicing from
  somatic mutations as a source of neoantigen candidates. Bioinformatics
  Advances, 4(1), vbae080.
  [https://doi.org/10.1093/bioadv/vbae080](https://doi.org/10.1093/bioadv/vbae080)
- Li, H., & Durbin, R. (2009). Fast and accurate short read alignment with
  Burrows–Wheeler transform. Bioinformatics, 25(14), 1754–1760.
  [https://doi.org/10.1093/bioinformatics/btp324](https://doi.org/10.1093/bioinformatics/btp324)
- Patro, R., Duggal, G., Love, M. I., Irizarry, R. A., & Kingsford, C. (2017).
  Salmon provides fast and bias-aware quantification of transcript expression.
  Nature Methods, 14(4), 417–419. https://doi.org/10.1038/nmeth.4197
- Bray, N. L., Pimentel, H., Melsted, P., & Pachter, L. (2016). Near-optimal
  probabilistic RNA-seq quantification. Nature Biotechnology, 34(5), 525–527.
  [https://doi.org/10.1038/nbt.3519](https://doi.org/10.1038/nbt.3519)
- Vasimuddin, Md., Misra, S., Li, H., & Aluru, S. (2019). Efficient
  Architecture-Aware Acceleration of BWA-MEM for Multicore Systems. 2019 IEEE
  International Parallel and Distributed Processing Symposium (IPDPS), 314–324.
  [https://doi.org/10.1109/IPDPS.2019.00041](https://doi.org/10.1109/IPDPS.2019.00041)
