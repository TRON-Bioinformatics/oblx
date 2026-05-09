rule link_snpeff:
    """
Create symlinks to the reference and GTF for snpEff index build.
"""
    input:
        fasta=get_genome_for_index_building,
        gtf=config.get("genome-gtf", "resources/ref_annot.gtf"),
    output:
        fasta_link=os.path.join(
            "indices/snpeff/data/",
            f'{config.get("genome-build", default_build)}.{config.get("release", default_release)}',
            "sequences.fa",
        ),
        gtf_link=os.path.join(
            "indices/snpeff/data/",
            f'{config.get("genome-build", default_build)}.{config.get("release", default_release)}',
            "genes.gtf",
        ),
    log:
        "logs/snpeff/link_snpeff.log",
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        ln -sr {input.fasta} {output.fasta_link} > {log} 2>&1
        ln -sr $(realpath {input.gtf}) {output.gtf_link} >> {log} 2>&1
        """


rule prepare_snpEff_config:
    """
Add the respective entry to the snpEff config file.

input:
    codon_mit_vertebrate (str): Path to file containing the vertebrate codon line from the default snpEff.config
params:
output:
"""
    input:
        fasta_link=rules.link_snpeff.output.fasta_link,
        gtf_link=rules.link_snpeff.output.gtf_link,
        codon_mit_vertebrate=workflow.source_path(
            "../resources/vertebrate_mitochondrial.txt"
        ),
    output:
        config_file=f"indices/snpeff/snpeff.config",
    log:
        "logs/snpeff/prepare_snpEff_config.log",
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    params:
        genome_version=(
            f"{config.get('genome-build', default_build)}."
            f"{config.get('release', default_release)}"
        ),
    shell:
        """
        cat {input.codon_mit_vertebrate} >> {output.config_file} 2> {log}
        echo '{params.genome_version}.genome : {params.genome_version}' >> {output.config_file} 2>> {log}
        echo '    {params.genome_version}.chrM.codonTable : Vertebrate_Mitochondrial' >> {output.config_file} 2>> {log}
        """


rule build_snpEff_index:
    """
Create the snpEff index.
"""
    input:
        fasta_link=rules.link_snpeff.output.fasta_link,
        gtf_link=rules.link_snpeff.output.gtf_link,
        config_file=rules.prepare_snpEff_config.output.config_file,
    output:
        os.path.abspath(
            os.path.join(
                "indices/snpeff/data/{genome_version}/snpEffectPredictor.bin",
            )
        ),
    log:
        "logs/snpeff/{genome_version}/snpeff-build-db.log",
    conda:
        "../envs/snpeff.yaml"
    container:
        config["container"].get("snpeff")
    resources:
        mem_mb=16000,
    params:
        data_dir=subpath(subpath(output[0], parent=True), parent=True),
    shell:
        "snpEff -Xmx{resources.mem_mb}m build "
        "-gtf22 "
        "-verbose "
        "-dataDir {params.data_dir} "
        "-config {input.config_file} "
        "-noCheckCds "
        "-noCheckProtein "
        "{wildcards.genome_version} "
        "> {log}"
