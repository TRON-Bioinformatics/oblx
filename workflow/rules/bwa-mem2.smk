rule link_bwa_fasta:
    """Create a symlink of the reference fasta into the bwa-mem2 index directory.

    input:
        fasta (str): Path to the fasta file that should be symlinked (either masked for human or default for mouse)
    output:
        fasta_link (str): Path to symlink reference fasta file in bwa directory
    """
    input:
        fasta = get_genome_for_index_building
    output:
        fasta_link = 'indices/bwa/ref_genome.fasta'
    shell:
        'ln -sr {input.fasta} {output.fasta_link}'

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
    conda: '../envs/bwa_mem2.yaml'
    resources:
        mem_mb = 100000
    threads:
        16
    log:
        'logs/indices/bwa/bwa-mem2-index.log'
    shell:
        'bwa-mem2 index -p {input.fasta} {input.fasta} &> {log}'


rule samtools_faidx_bwa:
    """
    Generate FASTA index of reference genome in bwa index dir
    """
    input:
        fasta = 'indices/bwa/ref_genome.fasta'
    output:
       fai = 'indices/bwa/ref_genome.fasta.fai'
    conda:
        '../envs/samtools.yaml'
    shell:
        '''
	    samtools faidx {input.fasta}
        '''
