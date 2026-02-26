rule link_snpeff:
    """
    Create symlinks to the reference and GTF for snpEff index build.
    """
    input:
        fasta = get_genome_for_index_building,
        gtf = config.get('genome-gtf', 'resources/ref_annot.gtf')
    output:
        fasta_link = os.path.join(
            'indices/snpeff/data/',
            f'{config.get("genome-build", default_build)}.{config.get("release", default_release)}',
            'sequences.fa'
        ),
        gtf_link = os.path.join(
            'indices/snpeff/data/',
            f'{config.get("genome-build", default_build)}.{config.get("release", default_release)}',
            'genes.gtf'
        )
    conda:
        "../envs/shellutils.yaml"
    container:
        config['container'].get('shell_utils')
    shell:
        '''
        ln -sr {input.fasta} {output.fasta_link}
        ln -sr $(realpath {input.gtf}) {output.gtf_link}
        '''


rule prepare_snpEff_config:
    """
    Add the respective entry to the snpEff config file.

    input:
        codon_mit_vertebrate (str): Path to file containing the vertebrate codon line from the default snpEff.config
    params:
    output:
    """
    input:
        fasta_link = rules.link_snpeff.output.fasta_link,
        gtf_link = rules.link_snpeff.output.gtf_link,
        codon_mit_vertebrate = os.path.join(
            workflow.basedir,
            'resources/vertebrate_mitochondrial.txt'
        )
    output:
        config_file = f'indices/snpeff/snpeff.config'
    params:
        genome_build = config.get('genome-build', default_build),
        release = config.get('release', default_release)
    conda:
        "../envs/shellutils.yaml"
    container:
        config['container'].get('shell_utils')
    shell:
        """
        cat {input.codon_mit_vertebrate} >> {output.config_file}
        echo '{params.genome_build}.{params.release}.genome : {params.genome_build}.{params.release}' >> {output.config_file}
        echo '    {params.genome_build}.{params.release}.chrM.codonTable : Vertebrate_Mitochondrial' >> {output.config_file}
        """


rule build_snpEff_index:
    """
    Create the snpEff index.
    """
    input:
        fasta_link = rules.link_snpeff.output.fasta_link,
        gtf_link = rules.link_snpeff.output.gtf_link,
        config_file = rules.prepare_snpEff_config.output.config_file
    output:
        os.path.abspath(os.path.join(
            'indices/snpeff/data/',
            f'{config.get("genome-build", default_build)}.{config.get("release", default_release)}',
            'snpEffectPredictor.bin'
        ))
    params:
        data_dir = os.path.abspath(Path(rules.link_snpeff.output.fasta_link).parents[1]),
    resources:
        mem_mb = 8000
    conda:
        '../envs/snpeff.yaml'
    container:
        config['container'].get('snpeff')
    log:
        'logs/snpeff/snpeff-build-db.log'
    shell:
        'snpEff -Xmx{resources.mem_mb}m build '
        '-gtf22 '
        '-verbose '
        '-dataDir {params.data_dir} '
        '-config {input.config_file} '
        '-noCheckCds '
        '-noCheckProtein '
        f'-v {config.get("genome-build", default_build)}.{config.get("release", default_release)} '
        '> {log}'
