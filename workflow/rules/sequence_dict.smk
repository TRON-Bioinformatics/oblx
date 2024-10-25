rule create_sequence_dict:
    input:
        genome_fasta = get_genome_for_index_building
    output:
        # replacing the fasta extension by .dict extension
        genome_dict = lambda wildcards, input:
            os.path.splitext(
                input.genome_fasta
            )[0] + '.dict'
    conda:
        'envs/gatk.yaml'
    shell:
        '''
        gatk CreateSequenceDictionary --REFERENCE {input.genome_fasta}
        '''
