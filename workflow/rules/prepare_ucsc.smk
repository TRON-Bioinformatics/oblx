rule repeatmasker_bed:
    input:
        rsmk = 'resources/ucsc_repeatmasker_dump.txt.gz'
    output:
        rsmk_bed = 'resources/ref_genome_repeatmasker.bed'
    shell:
        'zcat {input.rsmk} | awk -v OFS="\t" \'{print $6, $7-1, $8, $11, $2, $10}\' > resources/repeatmasker.bed && '
        'bedtools merge -s -c 4,5,6 -o distinct,distinct,distinct < resources/repeatmasker.bed > {output.rsmk_bed}'
