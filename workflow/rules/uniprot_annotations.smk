rule download_ensembl_external_data:
    """
Download external_data table from ENSEMBL MySQL dump to extract uniprot release used in ENSEMBL pipeline.
"""
    input:
        ensembl_remote=storage(
            "{}/release-{}/mysql/{}_core_{}_{}/external_db.txt.gz".format(
                config.get("ensembl_url").rstrip("/"),
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


rule download_uniprot_scripts:
    """
Download the UniProt scripts required for processing the .dat files.
"""
    input:
        varsplic_remote=storage(
            "https://ftp.ebi.ac.uk/pub/software/uniprot/varsplic/varsplic.pl"
        ),
        swissknife_remote=storage(
            (
                "https://sourceforge.net/projects/swissknife/files/swissknife/"
                f"{config['swissknife_version']}/"
                f"swissknife_{config['swissknife_version']}.tar.gz"
            )
        ),
    output:
        varsplic_script=temp("resources/uniprot/varsplic.pl"),
        swissknife_script=temp("resources/uniprot/swissknife.tar.gz"),
    log:
        "logs/pull_resources/download_uniprot_scripts.log",
    benchmark:
        "benchmarks/pull_resources/download_uniprot_scripts.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        exec &> "{log}"
        cp "{input.varsplic_remote}" "resources/uniprot/varsplic.pl"
        cp "{input.swissknife_remote}" "resources/uniprot/swissknife.tar.gz"
        """


rule gunzip_swissknife:
    """
Decompress the Swissknife tar.gz archive.
"""
    input:
        swissknife_script="resources/uniprot/swissknife.tar.gz",
    output:
        swissknife_dir=directory(temp("resources/uniprot/swissknife")),
    log:
        "logs/pull_resources/gunzip_swissknife.log",
    benchmark:
        "benchmarks/pull_resources/gunzip_swissknife.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        exec &> "{log}"
        mkdir -p "{output.swissknife_dir}"
        tar xzf "{input.swissknife_script}" \
            --strip-components=1 \
            -C "{output.swissknife_dir}"
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
        uniprot_fasta_sp="resources/uniprot/uniprot_reviewed_canonical.fasta",
        uniprot_fasta_tr="resources/uniprot/uniprot_unreviewed_canonical.fasta",
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
            --outfasta-sp "{output.uniprot_fasta_sp}" \
            --outfasta-tr "{output.uniprot_fasta_tr}" \
            --organism "{params.organism}"
        """


rule concat_uniprot_sp_tr_fasta:
    """
Concatenate the reviewed and unreviewed UniProt FASTA files into a single FASTA file.
"""
    input:
        uniprot_fasta_sp=rules.extract_uniprot_annot_from_dat.output.uniprot_fasta_sp,
        uniprot_fasta_tr=rules.extract_uniprot_annot_from_dat.output.uniprot_fasta_tr,
    output:
        uniprot_fasta="resources/uniprot/uniprot_reviewed_unreviewed_canonical.fasta",
    log:
        "logs/uniprot/concat_uniprot_sp_tr_fasta.log",
    benchmark:
        "benchmarks/uniprot/concat_uniprot_sp_tr_fasta.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    threads: 1
    shell:
        """
        exec &> "{log}"
        cat "{input.uniprot_fasta_sp}" "{input.uniprot_fasta_tr}" \
            > "{output.uniprot_fasta}"
        """


rule gunzip_uniprot_dat:
    """
Decompress the concatenated UniProtKB .dat.gz file.
"""
    input:
        swissprot_dat_gz=rules.extract_uniprot_snapshot.output.swissprot,
    output:
        swissprot_dat=temp("resources/uniprot/uniprot_sprot.dat"),
    log:
        "logs/uniprot/gunzip_uniprot_dat.log",
    benchmark:
        "benchmarks/uniprot/gunzip_uniprot_dat.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    threads: 1
    shell:
        """
        exec &> "{log}"
        gunzip -c "{input.swissprot_dat_gz}" > "{output.swissprot_dat}"
        """


rule generate_isoform_fasta:
    """
Generate a FASTA file containing all isoforms from the UniProt swissprot annotations.
The isoforms are only generated for Swiss-Prot entries as this is also the default
for the UniProt current release.
"""
    input:
        swissprot_dat=rules.gunzip_uniprot_dat.output.swissprot_dat,
        varsplic_script=rules.download_uniprot_scripts.output.varsplic_script,
        swissknife_dir=rules.gunzip_swissknife.output.swissknife_dir,
    output:
        isoform_fasta="resources/uniprot/uniprot_reviewed_isoforms_all.fasta",
        isoform_fasta_stats="resources/uniprot/uniprot_reviewed_isoforms_all.fasta.stats",
        isoform_fasta_err="resources/uniprot/uniprot_reviewed_isoforms_all.fasta.err",
    log:
        "logs/uniprot/generate_isoform_fasta.log",
    benchmark:
        "benchmarks/uniprot/generate_isoform_fasta.txt"
    conda:
        "../envs/perl.yaml"
    container:
        config["container"].get("perl")
    threads: 1
    shell:
        """
        exec &> "{log}"
        export PERL5LIB="{input.swissknife_dir}/lib:${{PERL5LIB:-}}"
        perl "{input.varsplic_script}" \
            -input "{input.swissprot_dat}" \
            -fasta "{output.isoform_fasta}" \
            -stats "{output.isoform_fasta_stats}" \
            -error "{output.isoform_fasta_err}"
        """


rule filter_uniprot_isoforms_fasta_for_organism:
    """
Filter the isoform FASTA file to include only isoforms from a specific organism.
"""
    input:
        isoform_fasta=rules.generate_isoform_fasta.output.isoform_fasta,
    output:
        filtered_isoform_fasta="resources/uniprot/uniprot_reviewed_isoforms.fasta",
    log:
        "logs/uniprot/filter_uniprot_reviewed_isoforms_for_organism.log",
    benchmark:
        "benchmarks/uniprot/filter_uniprot_reviewed_isoforms_for_organism.txt"
    conda:
        "../envs/seqkit.yaml"
    container:
        config["container"].get("seqkit")
    threads: 1
    params:
        organism=ENSEMBL_ORGANISM.replace("_", " "),
    shell:
        """
        exec &> "{log}"
        seqkit grep \
            --ignore-case \
            --by-name \
            --use-regexp \
            --pattern 'OS={params.organism}' \
            {input.isoform_fasta} \
            --out-file {output.filtered_isoform_fasta}
        """


rule concat_reviewed_unreviewed_canonical_isoforms:
    """
Concatenate reviewed canonical, unreviewed canonical and reviewed isoform
FASTA files into a single FASTA file.
"""
    input:
        reviewed_unreviewed_canonical=(
            "resources/uniprot/uniprot_reviewed_unreviewed_canonical.fasta"
        ),
        reviewed_isoforms="resources/uniprot/uniprot_reviewed_isoforms.fasta",
    output:
        concatenated=(
            "resources/uniprot/uniprot_reviewed_unreviewed_canonical_isoforms.fasta"
        ),
    log:
        "logs/uniprot/concat_reviewed_unreviewed_canonical_isoforms.log",
    benchmark:
        "benchmarks/uniprot/concat_reviewed_unreviewed_canonical_isoforms.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    threads: 1
    shell:
        """
        exec &> "{log}"
        cat {input.reviewed_unreviewed_canonical} {input.reviewed_isoforms} \
            > {output.concatenated}
        """


rule merge_gencode_to_uniprot:
    """
Merge GENCODE Swiss-Prot and TrEMBL mapping files with UniProt annotations to
create a comprehensive mapping of GENCODE transcripts to UniProt annotations.
"""
    input:
        uniprot_annotations=rules.extract_uniprot_annot_from_dat.output.uniprot_annot,
        sp_mapping="resources/ref_annot_metadata_SwissProt.tsv",
        tr_mapping="resources/ref_annot_metadata_TrEMBL.tsv",
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
