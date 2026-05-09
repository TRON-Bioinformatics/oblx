rule set_genome:
    """
Create a symlink of the reference fasta for index building.

When indexing mouse reference data, this is a symbolic
link to the primary assembly. For human this points to
the masked genome.

input:
    fasta (str): Path to the fasta file that should be symlinked (either
        masked for human or default for mouse).
output:
    genome (str): Path to symlink reference fasta file.
"""
    input:
        fasta=get_genome_for_index_building,
    output:
        genome="resources/ref_genome.fasta",
    log:
        "logs/faidx/set_genome.log",
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        "ln -sr {input.fasta} {output.genome} &> {log}"


rule samtools_faidx_ref_genome:
    """
Generate FASTA index of reference genome.

input:
    fasta (str): Path to reference genome fasta file.
output:
    fai (str): Path to FASTA index file.
"""
    input:
        fasta="resources/ref_genome.fasta",
    output:
        fai="resources/ref_genome.fasta.fai",
    log:
        "logs/faidx/samtools_faidx_ref_genome.log",
    conda:
        "../envs/samtools.yaml"
    container:
        config["container"].get("samtools")
    shell:
        """
        samtools faidx {input.fasta} &> {log}
        """
