rule link_bwa_fasta:
    input:
        fasta = get_genome_for_index_building
    output:
        fasta_link = 'indices/bwa/ref_genome.fasta'
    shell:
        'ln -s {input.fasta} {output.fasta_link}'

rule bwa_mem2_index:
    """bwa-mem2 index

    Rule to create a bwa index from the DNA fasta file.

    input:
        fasta (string): Path to DNA fasta file
    params:
        genomeDir (string): Path (dirname) to STAR index
        ramByte (int): Memory limit in byte for index generation
    output:
        genomeFile (string): Path to STAR index genome file
    """
    input:
        fasta = rules.link_bwa_fasta.output.fasta_link
    output:
        multiext(
            "indices/bwa/ref_genome.fasta", 
            ".0123", 
            ".amb", 
            ".ann",
            ".bwt.2bit.64",
            ".pac"
        )
    conda: 'envs/bwa.yaml'
    log:
        'indices/bwa/bwa-mem2-index.log'
    wrapper:
        "v3.10.2/bio/bwa-mem2/index"


rule samtools_faidx:
    """
    Generate FASTA index of reference genome in bwa index dir
    """
    input:
        fasta = 'indices/bwa/ref_genome.fasta'
    output:
       fai = 'indices/bwa/ref_genome.fasta.fai'
    conda:
        'envs/samtools.yaml'
    shell:
        '''
	    samtools faidx {input.fasta}
        '''
