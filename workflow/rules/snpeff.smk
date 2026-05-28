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
            f'{config["genome_build"]}.{config["release"]}',
            "sequences.fa",
        ),
        gtf_link=os.path.join(
            "indices/snpeff/data/",
            f'{config["genome_build"]}.{config["release"]}',
            "genes.gtf",
        ),
    log:
        "logs/snpeff/link_snpeff.log",
    benchmark:
        "benchmarks/snpeff/link_snpeff.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        exec &> "{log}"
        ln -sr "{input.fasta}" "{output.fasta_link}"
        ln -sr "$(realpath "{input.gtf}")" "{output.gtf_link}"
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
    benchmark:
        "benchmarks/snpeff/prepare_snpEff_config.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    params:
        genome_version=f"{config['genome_build']}.{config['release']}",
    shell:
        """
        exec &> "{log}"
        cat "{input.codon_mit_vertebrate}" \
            >> "{output.config_file}"
        echo "{params.genome_version}.genome :" \
            "{params.genome_version}" \
            >> "{output.config_file}"
        echo "    {params.genome_version}.chrM.codonTable :" \
            "Vertebrate_Mitochondrial" \
            >> "{output.config_file}"
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
    benchmark:
        "benchmarks/snpeff/{genome_version}/snpeff-build-db.txt"
    conda:
        "../envs/snpeff.yaml"
    container:
        config["container"].get("snpeff")
    resources:
        mem_mb=16000,
    params:
        data_dir=subpath(subpath(output[0], parent=True), parent=True),
    shell:
        """
        snpEff -Xmx{resources.mem_mb}m build \
            -gtf22 \
            -verbose \
            -dataDir "{params.data_dir}" \
            -config "{input.config_file}" \
            -noCheckCds \
            -noCheckProtein \
            "{wildcards.genome_version}" \
            &> "{log}"
        """
