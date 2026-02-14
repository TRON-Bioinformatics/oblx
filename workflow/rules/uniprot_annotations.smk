#rule transcript2uniprot_mapping:
#    """
#    Generate transcript_id to uniprot accession mapping.
#
#    input:
#        gencode2swissprot (str): Path to Gencode to SwissProt mapping file.
#        gencode2trembl (str): Path to Gencode to TrEMBL mapping file.
#    output:
#        transcript2uniprot (str): Path to transcript to uniprot mapping file.
#    """
#    input:
#        gencode2swissprot = rules.download_gencode_data.output.swissprot,
#        gencode2trembl = rules.download_gencode_data.output.trembl,
#    output:
#        transcript2uniprot = 'resources/uniprot/transcript2uniprot.tsv',
#    conda:
#        "../envs/shellutils.yaml"
#    threads: 1
#    log:
#        'logs/uniprot_annotations/transcript2uniprot_mapping.log'
#    shell:
#        """
#        echo -e 'transcript_id\tEntry\tEntry name' > resources/uniprot/header.tsv
#
#        cat resources/uniprot/header.tsv {input.gencode2swissprot} {input.gencode2trembl} > {output.transcript2uniprot}
#
#        rm resources/uniprot/header.tsv
#        """

rule merge_gencode_to_uniprot:
    input:
        uniprot_annotations = rules.download_uniprot.output.uniprot_annotations,
        sp_mapping = rules.download_gencode_data.output.swissprot,
        tr_mapping = rules.download_gencode_data.output.trembl,
    output:
        uniprot_annotations_merged = 'resources/uniprot/uniprot_annotations.tsv',
    conda:
        "../envs/python.yaml"
    threads: 1
    log:
        'logs/uniprot/merge_gencode_to_uniprot.log'
    shell:
        """
        python ../scripts/merge_gencode_to_uniprot.py \
        --sp-mapping {input.sp_mapping} \
        --tr-mapping {input.tr_mapping} \
        --uniprot {input.uniprot_annotations} \
        --output {output.uniprot_annotations_merged}
        """
