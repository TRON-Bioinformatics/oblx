rule bowtie2_index:
    """
Create a bowtie2 index from the reference genome file.

input:
    fasta (str): Path to DNA fasta file.
output:
    index_files (list): List of bowtie2 index files.
"""
    input:
        fasta="resources/ref_genome.fasta",
    output:
        index_files=multiext(
            "indices/bowtie2/genome",
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2",
        ),
    log:
        "logs/bowtie2/bowtie2-index.log",
    conda:
        "../envs/bowtie2.yaml"
    container:
        config["container"].get("bowtie2")
    threads: 8
    resources:
        mem_mb=16000,
    params:
        prefix=lambda wildcards, output: get_bowtie2_prefix(output.index_files),
    shell:
        """
        bowtie2-build \
            --threads {threads} \
            "{input.fasta}" \
            "{params.prefix}" \
            &> "{log}"
        """
