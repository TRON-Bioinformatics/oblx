rule chrom_sizes:
    input:
        fasta_index = 'resources/ref_genome.fasta'
    output:
        'resources/chromosome_sizes.txt'
    shell:
        'cut -f 1,2 {input.fasta_index} > {output}'

rule gencode_exome_bed:
    """
    Generate generic exome definition based on GENCODE basic transcript definition
    """
    input:
        gtf = config.get(
            'genome-gtf', 'resources/ref_annot.gtf'
        ),
        chrom_sizes = rules.chrom_sizes.output
    params:
        intron_slop = config.get('intron-slop', 20)
    output:
        exome_interval = 'resources/exome_definition/ref_exome.bed'
    conda:
        '../envs/bedtools.yaml'
    log:
        'logs/exome_creation.log'
    script:
        '../scripts/make_exome_bed.sh'