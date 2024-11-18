rule kallisto_index:
    input:
        genome = 'resources/ref_genome.fasta',
        gtf = 'resources/ref_annot.gtf'
    output:
        index = "indices/kallisto/ref_transcript.idx",
        tx2gene = "indices/kallisto/ref_transcript_to_gene.tsv",
        cdna = "indices/kallisto/ref_cdna.fa"
    params:
        extra="",
    log:
        "logs/kallisto_index.log",
    threads: 2
    conda:
        '../envs/kb_tools.yaml'
    shell:
        'kb ref --workflow=standard '
        '-i {output.index} -g {output.tx2gene} -f1 {output.cdna} '
        '--include-attribute gene_biotype:protein_coding '
        '--include-attribute gene_biotype:lncRNA '
        '--include-attribute gene_biotype:lincRNA '
        '--include-attribute gene_biotype:antisense '
        '--include-attribute gene_biotype:IG_LV_gene '
        '--include-attribute gene_biotype:IG_V_gene '
        '--include-attribute gene_biotype:IG_V_pseudogene '
        '--include-attribute gene_biotype:IG_D_gene '
        '--include-attribute gene_biotype:IG_J_gene '
        '--include-attribute gene_biotype:IG_J_pseudogene '
        '--include-attribute gene_biotype:IG_C_gene '
        '--include-attribute gene_biotype:IG_C_pseudogene '
        '--include-attribute gene_biotype:TR_V_gene '
        '--include-attribute gene_biotype:TR_V_pseudogene '
        '--include-attribute gene_biotype:TR_D_gene '
        '--include-attribute gene_biotype:TR_J_gene '
        '--include-attribute gene_biotype:TR_J_pseudogene '
        '--include-attribute gene_biotype:TR_C_gene '
        '{input.genome} {input.gtf} &> {log}'