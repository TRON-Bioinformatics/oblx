rule link_bwa_mem2_fasta:
    """
Create a symlink of the reference fasta into the bwa-mem2 index directory.

input:
    fasta (str): Path to the fasta file that should be symlinked (either
        masked for human or default for mouse).
output:
    fasta_link (str): Path to symlink reference fasta file in bwa-mem2
        directory.
"""
    input:
        fasta=get_genome_for_index_building,
    output:
        fasta_link="indices/bwa_mem2/ref_genome.fasta",
    log:
        "logs/bwa_mem2/link_bwa_mem2_fasta.log",
    benchmark:
        "benchmarks/bwa_mem2/link_bwa_mem2_fasta.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        exec &> "{log}"
        ln -sr "{input.fasta}" "{output.fasta_link}"
        """


rule bwa_mem2_index:
    """
Create a bwa-mem2 index from the reference genome file.

input:
    fasta (str): Path to DNA fasta file.
output:
    index_files (list): List of bwa-mem2 index files.
"""
    input:
        fasta=rules.link_bwa_mem2_fasta.output.fasta_link,
    output:
        index_files=multiext(
            "indices/bwa_mem2/ref_genome.fasta",
            ".0123",
            ".amb",
            ".ann",
            ".bwt.2bit.64",
            ".pac",
        ),
    log:
        "logs/bwa_mem2/bwa-mem2-index.log",
    benchmark:
        "benchmarks/bwa_mem2/bwa-mem2-index.txt"
    conda:
        "../envs/bwa_mem2.yaml"
    container:
        config["container"].get("bwa_mem2")
    threads: 1
    resources:
        # https://github.com/bwa-mem2/bwa-mem2
        # Indexing the reference sequence (Requires 28N GB memory 
        # where N is the size of the reference sequence).
        mem_mb=100_000,
    shell:
        """
        exec &> "{log}"
        bwa-mem2 index -p "{input.fasta}" "{input.fasta}"
        """


rule samtools_faidx_bwa_mem2:
    """
Generate FASTA index of reference genome in bwa index dir.

input:
    fasta (str): Path to reference genome fasta file.
output:
    fai (str): Path to FASTA index file.
"""
    input:
        fasta="indices/bwa_mem2/ref_genome.fasta",
    output:
        fai="indices/bwa_mem2/ref_genome.fasta.fai",
    log:
        "logs/bwa_mem2/samtools_faidx_bwa_mem2.log",
    benchmark:
        "benchmarks/bwa_mem2/samtools_faidx_bwa_mem2.txt"
    conda:
        "../envs/samtools.yaml"
    container:
        config["container"].get("samtools")
    shell:
        """
        exec &> "{log}"
        samtools faidx "{input.fasta}"
        """
