rule samtools_faidx:
    """
    Generate FASTA index of reference genome in bwa index dir
    """
    input:
        fasta = 'resources/ref_genome_masked_GRC_exclusions.fasta'
    output:
       fai = 'resources/ref_genome_masked_GRC_exclusions.fasta.fai'
    conda:
        'envs/samtools.yaml'
    shell:
        '''
	    samtools faidx {input.fasta}
        '''
