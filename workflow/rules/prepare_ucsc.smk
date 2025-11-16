rule repeatmasker_bed:
    """
    Convert UCSC database dump of repeatmasker annotation into BED.
    """
    input:
        rmsk = 'resources/ucsc_repeatmasker_dump.txt.gz'
    output:
        rmsk_bed = 'resources/ref_genome_repeatmasker.bed'
    conda:
        '../envs/bedtools.yaml'
    conda:
        "../env/shellutils.yaml"
    log:
        'logs/rmsk_creation.log'
    script:
        '../scripts/make_RMSK_bed.sh'
