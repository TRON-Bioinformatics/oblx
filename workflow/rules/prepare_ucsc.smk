rule repeatmasker_bed:
    input:
        rmsk = 'resources/ucsc_repeatmasker_dump.txt.gz'
    output:
        rmsk_bed = 'resources/ref_genome_repeatmasker.bed'
    conda:
        '../envs/bedtools.yaml'
    #shadow: 'shallow'
    log:
        'logs/rmsk_creation.log'
    script:
        '../scripts/make_RMSK_bed.sh'
