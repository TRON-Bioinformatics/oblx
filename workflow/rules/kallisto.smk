rule kallisto_index:
    """
Generate kallisto index with kb_python suite.

input:
    genome (str): Path to the genome fasta file.
    gtf (str): Path to reference annotation.
output:
    index (str): Path to kallisto index.
    tx2gene (str): Path to kallisto transcript to gene mapping.
    cdna (str): Path to kallisto cDNA file.
"""
    input:
        genome="resources/ref_genome.fasta",
        gtf="resources/ref_annot.gtf",
    output:
        index="indices/kallisto/ref_transcript.idx",
        tx2gene="indices/kallisto/ref_transcript_to_gene.tsv",
        cdna="indices/kallisto/ref_cdna.fa",
    log:
        "logs/kallisto/kallisto_index.log",
    benchmark:
        "benchmarks/kallisto/kallisto_index.txt"
    conda:
        "../envs/kb_tools.yaml"
    container:
        config["container"].get("kb_tools")
    threads: 2
    shell:
        """
        exec &> "{log}"
        kb ref --workflow=standard \
        -i "{output.index}" -g "{output.tx2gene}" -f1 "{output.cdna}" \
        --include-attribute gene_type:protein_coding \
        --include-attribute gene_type:lncRNA \
        --include-attribute gene_type:lincRNA \
        --include-attribute gene_type:antisense \
        --include-attribute gene_type:IG_LV_gene \
        --include-attribute gene_type:IG_V_gene \
        --include-attribute gene_type:IG_V_pseudogene \
        --include-attribute gene_type:IG_D_gene \
        --include-attribute gene_type:IG_J_gene \
        --include-attribute gene_type:IG_J_pseudogene \
        --include-attribute gene_type:IG_C_gene \
        --include-attribute gene_type:IG_C_pseudogene \
        --include-attribute gene_type:TR_V_gene \
        --include-attribute gene_type:TR_V_pseudogene \
        --include-attribute gene_type:TR_D_gene \
        --include-attribute gene_type:TR_J_gene \
        --include-attribute gene_type:TR_J_pseudogene \
        --include-attribute gene_type:TR_C_gene \
        "{input.genome}" "{input.gtf}"
        """
