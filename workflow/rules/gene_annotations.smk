rule transcript_to_gene_mapping:
    """
Generate a TSV file mapping Ensembl transcript ids to gene ids.
"""
    input:
        gtf="resources/ref_annot.gtf",
        script=workflow.source_path("../scripts/tx2gene.R"),
    output:
        tx2gene="resources/ref_annot_transcript2gene.tsv",
    log:
        "logs/pull_resources/transcript_to_gene_mapping.log",
    benchmark:
        "benchmarks/pull_resources/transcript_to_gene_mapping.txt"
    conda:
        "../envs/renv.yaml"
    container:
        config["container"].get("splice2neo")
    resources:
        mem_mb=16000,
    shell:
        """
        Rscript "{input.script}" \
            "{input.gtf}" "{output.tx2gene}" &> "{log}"
        """


rule gene_to_hgnc_mapping:
    """
Generate a TSV file mapping Ensembl gene ids to HGNC gene symbols.
"""
    input:
        gtf="resources/ref_annot.gtf",
        script=workflow.source_path("../scripts/get_annotation_data.py"),
    output:
        mapping_table="resources/ref_annot_gene2symbol.tsv",
    log:
        "logs/pull_resources/gene_to_hgnc_mapping.log",
    benchmark:
        "benchmarks/pull_resources/gene_to_hgnc_mapping.txt"
    conda:
        "../envs/pandas.yaml"
    container:
        config["container"].get("scipy-notebook")
    resources:
        mem_mb=16000,
    shell:
        """
        exec &> "{log}"
        python "{input.script}" \
            --gtf "{input.gtf}" \
            --outfile "{output.mapping_table}"
        """


rule canonical_junction_list:
    """
Extract canoncial splice junctions from GENCODE reference transcripts.
"""
    input:
        gtf="resources/ref_annot.gtf",
        script=workflow.source_path("../scripts/canonical_splice_junctions.R"),
    output:
        canonical_juncs="resources/ref_annot_splice_sites.tsv",
    log:
        "logs/pull_resources/canonical_junction_list.log",
    benchmark:
        "benchmarks/pull_resources/canonical_junction_list.txt"
    conda:
        "../envs/renv.yaml"
    container:
        config["container"].get("splice2neo")
    resources:
        mem_mb=16000,
    shell:
        """
        Rscript "{input.script}" \
            "{input.gtf}" "{output.canonical_juncs}" &> "{log}"
        """
