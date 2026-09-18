rule download_ensembl_external_data:
    """
Download external_data table from ENSEMBL MySQL dump to extract uniprot release used in ENSEMBL pipeline.
"""
    input:
        ensembl_remote=storage(
            "https://ftp.ensembl.org/pub/release-{}/mysql/{}_core_{}_{}/external_db.txt.gz".format(
                ENSEMBL_VERSION,
                ENSEMBL_ORGANISM,
                ENSEMBL_VERSION,
                (
                    # this is the assembly build e.g. 39 for mouse or 38 for human
                    ENSEMBL_ASSEMBLY_BUILD
                    if is_gencode_organism
                    # for other organisms that does not always follows the build
                    # version, e.g. for rattus_norvegicus: 1
                    else config.get("ensembl_mysql_build")
                ),
            )
        ),
    output:
        external_data=temp("resources/uniprot/external_data.txt.gz"),
    log:
        "logs/pull_resources/ensembl_external_data.log",
    benchmark:
        "benchmarks/pull_resources/ensembl_external_data.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        exec &> "{log}"
        cp "{input.ensembl_remote}" "{output.external_data}"
        """


checkpoint extract_uniprot_release_from_ensembl_external_data:
    """
Extract the UniProt release version from the ENSEMBL external_data MySQL table.
"""
    input:
        external_data="resources/uniprot/external_data.txt.gz",
        script=workflow.source_path("../scripts/extract_uniprot_release.py"),
    output:
        uniprot_release="resources/uniprot/uniprot_release.txt",
    log:
        "logs/pull_resources/extract_uniprot_release_from_ensembl_external_data.log",
    benchmark:
        "benchmarks/pull_resources/extract_uniprot_release_from_ensembl_external_data.txt"
    conda:
        "../envs/pull_uniprot.yaml"
    container:
        config["container"].get("scipy-notebook")
    shell:
        """
        exec &> "{log}"
        python {input.script} \
            --external_data "{input.external_data}" \
            --outfile "{output.uniprot_release}"
        """


rule download_uniprot_snapshot:
    """
Download the UniProt snapshot release from the UniProt FTP server.
"""
    input:
        uniprot_release=uniprot_snapshot_url,
    output:
        uniprot_snapshot=temp("resources/uniprot/uniprot_snapshot.tar.gz"),
    log:
        "logs/pull_resources/download_uniprot_snapshot.log",
    benchmark:
        "benchmarks/pull_resources/download_uniprot_snapshot.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        exec &> "{log}"
        cp "{input.uniprot_release}" "{output.uniprot_snapshot}"
        """


rule extract_uniprot_snapshot:
    """
Extract the UniProt snapshot release to obtain SwissProt and TrEMBL data.
"""
    input:
        uniprot_snapshot="resources/uniprot/uniprot_snapshot.tar.gz",
    output:
        swissprot=temp("resources/uniprot/uniprot_sprot.dat.gz"),
        trembl=temp("resources/uniprot/uniprot_trembl.dat.gz"),
    log:
        "logs/pull_resources/extract_uniprot_snapshot.log",
    benchmark:
        "benchmarks/pull_resources/extract_uniprot_snapshot.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        exec &> "{log}"
        tar xzf "{input.uniprot_snapshot}" -C resources/uniprot uniprot_trembl.dat.gz uniprot_sprot.dat.gz
        """


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
