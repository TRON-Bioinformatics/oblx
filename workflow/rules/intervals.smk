rule chrom_sizes:
    """
Generate chromosome size table from fasta index.

input:
    fasta_index (str): Path to FASTA index file.
output:
    chrom_size_file (str): Path to chromosome sizes table.
"""
    input:
        fasta_index="resources/ref_genome.fasta.fai",
    output:
        chrom_size_file="resources/chromosome_sizes.txt",
    log:
        "logs/intervals/chrom_sizes.log",
    benchmark:
        "benchmarks/intervals/chrom_sizes.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        exec &> "{log}"
        cut -f 1,2 "{input.fasta_index}" > "{output.chrom_size_file}"
        """


rule exome_bed:
    """
Generate generic exome definition based on GENCODE basic transcript
definition.

input:
    gtf (str): Path to GTF file.
    chrom_sizes (str): Path to chromosome sizes table.
params:
    intron_slop (int): Number of bases to extend exons (from
        `bedtools slop`).
    exome_transcript_definition (str): Tag to filter transcripts.
output:
    exome_interval (str): Path to exome BED file.
"""
    input:
        gtf=config.get("genome-gtf", "resources/ref_annot.gtf"),
        chrom_sizes=rules.chrom_sizes.output,
        script=workflow.source_path("../scripts/make_exome_bed.sh"),
    output:
        exome_interval="resources/exome_definition/ref_exome.bed",
    log:
        "logs/exome_creation.log",
    benchmark:
        "benchmarks/exome_creation.txt"
    conda:
        "../envs/bedtools.yaml"
    container:
        config["container"].get("bedtools")
    params:
        intron_slop=config.get("intron_slop", 20),
        exome_transcript_definition=config.get("exome_transcript_definition", "basic"),
    shell:
        """
        bash "{input.script}" \
            "{input.gtf}" "{input.chrom_sizes}" \
            "{params.exome_transcript_definition}" "{params.intron_slop}" \
            "{output.exome_interval}" &> "{log}"
        """


rule cds_bed:
    """
Generate generic CDS definition based on GENCODE transcripts.
CDS regions are merged. Based on DeepVariant RNA-seq variant calling
tutorial.
"""
    input:
        gtf=config.get("genome-gtf", "resources/ref_annot.gtf"),
        script=workflow.source_path("../scripts/make_cds_bed.sh"),
    output:
        cds_interval="resources/exome_definition/ref_cds.bed",
    log:
        "logs/cds_creation.log",
    benchmark:
        "benchmarks/cds_creation.txt"
    conda:
        "../envs/bedtools.yaml"
    container:
        config["container"].get("bedtools")
    shell:
        """
        bash "{input.script}" \
            "{input.gtf}" \
            "{output.cds_interval}" &> "{log}"
        """


rule zip_and_index_exome_and_cds_bed:
    """Compress and index bed files with bgzip and tabix.

This is required e.g. for Strelka2.
"""
    input:
        gencode_bed="resources/exome_definition/ref_{feature}.bed",
    output:
        gencode_bed_gz="resources/exome_definition/ref_{feature}.bed.gz",
        gencode_bed_gz_tbi="resources/exome_definition/ref_{feature}.bed.gz.tbi",
    log:
        "logs/pull_resources/zip_and_index_exome_bed_{feature}.log",
    benchmark:
        "benchmarks/pull_resources/zip_and_index_exome_bed_{feature}.txt"
    conda:
        "../envs/bcftools.yaml"
    container:
        config["container"].get("bcftools")
    shell:
        """
        exec &> "{log}"
        bgzip -c "{input.gencode_bed}" > "{output.gencode_bed_gz}"
        tabix -p bed "{output.gencode_bed_gz}"
        """
