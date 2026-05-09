rule repeatmasker_bed:
    """
Convert UCSC database dump of repeatmasker annotation into BED.
"""
    input:
        rmsk="resources/ucsc_repeatmasker_dump.txt.gz",
        script=workflow.source_path("../scripts/make_RMSK_bed.sh"),
    output:
        rmsk_bed="resources/ref_genome_repeatmasker.bed",
    log:
        "logs/rmsk_creation.log",
    conda:
        "../envs/bedtools.yaml"
    container:
        config["container"].get("bedtools")
    shell:
        """
        bash {input.script} {input.rmsk} {output.rmsk_bed} {log}
        """
