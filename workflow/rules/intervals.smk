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
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        exec 2> {log}
        cut -f 1,2 {input.fasta_index} > {output.chrom_size_file}
        """


rule gencode_exome_bed:
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
    output:
        exome_interval="resources/exome_definition/ref_exome.bed",
    log:
        "logs/exome_creation.log",
    conda:
        "../envs/bedtools.yaml"
    container:
        config["container"].get("bedtools")
    params:
        intron_slop=config.get("intron-slop", 20),
        exome_transcript_definition=config.get("exome_transcript_definition", "basic"),
    script:
        "../scripts/make_exome_bed.sh"
