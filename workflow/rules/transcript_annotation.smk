rule annotation_R:
    """Prepare annotation data for the splice2neo R package.

This rule creates a TxDb (sqlite) database of
the reference transcript annotation and a 2Bit
representation of the genomic fasta file.

input:
    fasta (str): Path to DNA fasta file.
    gtf (str): Path to GTF file.
output:
    txdb (str): Path to TxDb sqlite database.
    twobit_genome (str): Path to 2Bit DNA reference file.
    serialized_transcripts (str): Path to transcripts RDS file.
    serialized_transcript_ranges (str): Path to transcript ranges RDS file.
    serialized_cds (str): Path to CDS RDS file.
"""
    input:
        fasta="resources/ref_genome.fasta",
        gtf="resources/ref_annot.gtf",
        script=workflow.source_path("../scripts/annotation2rds.R"),
    output:
        txdb="indices/R/ref_annot_txdb.sqlite",
        twobit_genome="indices/R/ref_genome.2bit",
        serialized_transcripts="indices/R/ref_transcripts.Rds",
        serialized_transcript_ranges="indices/R/ref_transcript_ranges.Rds",
        serialized_cds="indices/R/ref_cds.Rds",
    log:
        "logs/annotation_R.log",
    benchmark:
        "benchmarks/annotation_R.txt"
    conda:
        "../envs/renv.yaml"
    container:
        config["container"].get("splice2neo")
    resources:
        mem_mb=32000,
    shell:
        """
        Rscript {input.script} \
            {input.gtf} {input.fasta} \
            {output.txdb} {output.twobit_genome} \
            {output.serialized_transcripts} {output.serialized_transcript_ranges} \
            {output.serialized_cds} > {log} 2>&1
        """
