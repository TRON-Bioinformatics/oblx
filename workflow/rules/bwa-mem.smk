rule link_bwa_mem_fasta:
    """
Create a symlink of the reference fasta into the bwa index directory.

input:
    fasta (str): Path to the fasta file that should be symlinked (either
        masked for human or default for mouse).
output:
    fasta_link (str): Path to symlink reference fasta file in bwa directory.
"""
    input:
        fasta=get_genome_for_index_building,
    output:
        fasta_link="indices/bwa_mem/ref_genome.fasta",
    log:
        "logs/bwa_mem/link_bwa_mem_fasta.log",
    benchmark:
        "benchmarks/bwa_mem/link_bwa_mem_fasta.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        exec &> "{log}"
        ln -sr "{input.fasta}" "{output.fasta_link}"
        """


rule bwa_mem_index:
    """
Create a bwa index from the reference genome file.

input:
    fasta (str): Path to DNA fasta file.
output:
    index_files (list): List of bwa index files.
"""
    input:
        fasta=rules.link_bwa_mem_fasta.output.fasta_link,
    output:
        index_files=multiext(
            "indices/bwa_mem/ref_genome.fasta",
            ".amb",
            ".ann",
            ".bwt",
            ".pac",
            ".sa",
        ),
    log:
        "logs/bwa_mem/bwa-index.log",
    benchmark:
        "benchmarks/bwa_mem/bwa-index.txt"
    conda:
        "../envs/bwa.yaml"
    container:
        config["container"].get("bwa")
    threads: 1
    resources:
        mem_mb=100_000,
    shell:
        """
        exec &> "{log}"
        bwa index -p "{input.fasta}" "{input.fasta}"
        """


rule samtools_faidx_bwa_mem:
    """
Generate FASTA index of reference genome in bwa index dir.

input:
    fasta (str): Path to reference genome fasta file.
output:
    fai (str): Path to FASTA index file.
"""
    input:
        fasta="indices/bwa_mem/ref_genome.fasta",
    output:
        fai="indices/bwa_mem/ref_genome.fasta.fai",
    log:
        "logs/bwa_mem/samtools_faidx_bwa_mem.log",
    benchmark:
        "benchmarks/bwa_mem/samtools_faidx_bwa_mem.txt"
    conda:
        "../envs/samtools.yaml"
    container:
        config["container"].get("samtools")
    shell:
        """
        exec &> "{log}"
        samtools faidx "{input.fasta}"
        """
