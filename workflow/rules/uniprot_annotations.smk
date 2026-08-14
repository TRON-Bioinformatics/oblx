rule concat_uniprot_dat:
    """
Concatenate Swiss-Prot and TrEMBL snapshot .dat.gz files into a single gzipped UniProtKB database.

"""
    input:
        swissprot=rules.extract_uniprot_snapshot.output.swissprot,
        trembl=rules.extract_uniprot_snapshot.output.trembl,
    output:
        uniprot_dat=temp("resources/uniprot/uniprot.dat.gz"),
    log:
        "logs/uniprot/concat_uniprot_dat.log",
    benchmark:
        "benchmarks/uniprot/concat_uniprot_dat.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    threads: 1
    shell:
        """
        exec &> "{log}"
        cat "{input.swissprot}" "{input.trembl}" > "{output.uniprot_dat}"
        """


rule extract_uniprot_annot_from_dat:
    """
Extract UniProt annotations from a concatenated UniProtKB .dat.gz file.
"""
    input:
        uniprot_dat=rules.concat_uniprot_dat.output.uniprot_dat,
        script=workflow.source_path(
            "../scripts/programmatically_get_uniprot_from_dat.py"
        ),
    output:
        uniprot_annot="resources/uniprot/uniprot_annotations_raw.tsv",
    log:
        "logs/uniprot/extract_uniprot_annot_from_dat.log",
    benchmark:
        "benchmarks/uniprot/extract_uniprot_annot_from_dat.txt"
    conda:
        "../envs/biopython.yaml"
    container:
        config["container"].get("biopython")
    threads: 1
    params:
        organism=config["organism"],
    shell:
        """
        exec &> "{log}"
        python "{input.script}" \
            --database "{input.uniprot_dat}" \
            --outfile "{output.uniprot_annot}" \
            --organism "{params.organism}"
        """


rule merge_gencode_to_uniprot:
    """
Merge GENCODE Swiss-Prot and TrEMBL mapping files with UniProt annotations to
create a comprehensive mapping of GENCODE transcripts to UniProt annotations.
"""
    input:
        uniprot_annotations=rules.extract_uniprot_annot_from_dat.output.uniprot_annot,
        sp_mapping=rules.download_gencode_data.output.swissprot,
        tr_mapping=rules.download_gencode_data.output.trembl,
        script=workflow.source_path("../scripts/merge_gencode_to_uniprot.py"),
    output:
        uniprot_annotations_merged="resources/uniprot/uniprot_annotations.tsv",
    log:
        "logs/uniprot/merge_gencode_to_uniprot.log",
    benchmark:
        "benchmarks/uniprot/merge_gencode_to_uniprot.txt"
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
