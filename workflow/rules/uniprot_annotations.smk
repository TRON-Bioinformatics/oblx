rule merge_gencode_to_uniprot:
    input:
        uniprot_annotations=rules.download_uniprot.output.uniprot_annotations,
        sp_mapping=rules.download_gencode_data.output.swissprot,
        tr_mapping=rules.download_gencode_data.output.trembl,
        script=workflow.source_path("../scripts/merge_gencode_to_uniprot.py"),
    output:
        uniprot_annotations_merged="resources/uniprot/uniprot_annotations.tsv",
    log:
        "logs/uniprot/merge_gencode_to_uniprot.log",
    conda:
        "../envs/pandas.yaml"
    container:
        config["container"].get("scipy-notebook")
    threads: 1
    shell:
        """
        exec &> "{log}"
        python "{input.script}" \
        --sp-mapping "{input.sp_mapping}" \
        --tr-mapping "{input.tr_mapping}" \
        --uniprot "{input.uniprot_annotations}" \
        --outfile "{output.uniprot_annotations_merged}"
        """
