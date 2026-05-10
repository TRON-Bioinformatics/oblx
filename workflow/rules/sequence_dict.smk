rule create_sequence_dict:
    """
Create sequence dictionary for reference genome, comprising essentially the
SAM SQ header lines characterizing the reference sequence (name, length,
md5sum, file URL).

input:
    genome_fasta (str): Path to reference genome fasta file.
output:
    genome_dict (str): Path to sequence dictionary file.
"""
    input:
        genome_fasta="resources/ref_genome.fasta",
    output:
        genome_dict="resources/ref_genome.dict",
    log:
        "logs/sequence_dict/create_sequence_dict.log",
    conda:
        "../envs/gatk4.yaml"
    container:
        config["container"].get("gatk4")
    shell:
        """
        exec &> "{log}"
        gatk CreateSequenceDictionary \
            --REFERENCE "{input.genome_fasta}" \
            --OUTPUT "{output.genome_dict}"
        """
