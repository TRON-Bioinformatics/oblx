rule merge_gencode_to_uniprot:
    input:
        uniprot_annotations = rules.download_uniprot.output.uniprot_annotations,
        sp_mapping = rules.download_gencode_data.output.swissprot,
        tr_mapping = rules.download_gencode_data.output.trembl,
    output:
        uniprot_annotations_merged = 'resources/uniprot/uniprot_annotations.tsv',
    params:
        python_script = os.path.join(workflow.basedir, 'scripts/merge_gencode_to_uniprot.py')
    conda:
        "../envs/pandas.yaml"
    container:
        config['container'].get('python')
    threads: 1
    log:
        'logs/uniprot/merge_gencode_to_uniprot.log'
    shell:
        """
        python {params.python_script} \
        --sp-mapping {input.sp_mapping} \
        --tr-mapping {input.tr_mapping} \
        --uniprot {input.uniprot_annotations} \
        --outfile {output.uniprot_annotations_merged}
        """
