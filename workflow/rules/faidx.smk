rule set_genome:
    input:
        fasta = get_genome_for_index_building
    output:
        genome = 'resources/ref_genome.fasta'
    shell:
        'ln -sr {input.fasta} {output.genome}'

rule samtools_faidx_ref_genome:
    """
    Generate FASTA index of reference genome in bwa index dir
    """
    input:
        fasta = 'resources/ref_genome.fasta'
    output:
       fai = 'resources/ref_genome.fasta.fai'
    conda:
        '../envs/samtools.yaml'
    shell:
        '''
	    samtools faidx {input.fasta}
        '''
