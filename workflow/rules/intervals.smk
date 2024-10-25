rule generate_exon_bed:
    input:
        gtf = config.get(
            'genome-gtf', 'resources/ref_annot.gtf'
        )
    output:
        exon_bed = 'resources/ref_exons.bed'
    shell:
        'awk \'{if ($3 == "exon") print $0}\' {input.gtf} | '
        'grep \'tag "basic"\' | bedtools sort | bedtools merge > {output.exon_bed}'

rule chrom_sizes:
    input:
        fasta_index = 'resources/ref_genome_masked_GRC_exclusions.fasta.fai'
    output:
        'resources/chromosome_sizes.txt'
    shell:
        'cut -f 1,2 {input.fasta_index} > {output}'

rule gencode_exome_bed:
    input:
        exon_bed = rules.generate_exon_bed.exon_bed,
        chrom_sizes = rules.chrom_sizes.output
    params:
        intron_slop = config.get('intron-slop', 20)
    output:
        exome_interval = 'resources/exome_definition/ref_exome.bed'
    shell:
        'bedtools slop -i {input.exon_bed} -g {input.chrom_sizes} -b {params.intron_slop} | bedtools merge > {output.exome_interval}'