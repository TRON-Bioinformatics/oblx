rule create_sequence_dict:
    input:
        genome_fasta = 'resources/ref_genome.fasta'
    output:
        genome_dict = 'resources/ref_genome.dict'
    conda:
        '../envs/gatk4.yaml'
    shell:
        '''
        gatk CreateSequenceDictionary --REFERENCE {input.genome_fasta} --OUTPUT {output.genome_dict}
        '''
