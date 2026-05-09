rule salmon_decoy:
    """
Generate salmon decoys. Based on https://snakemake-wrappers.readthedocs.io/en/v3.1.0/wrappers/salmon/decoys.html.

input:
    transcriptome (str): Path to transcriptome fasta file.
    genome (str): Path to genome fasta file.
output:
    gentrome (str): Path to hybrid genome & transcriptome (gentrome) fasta
        file.
    decoys (str): Path to decoys text file.
"""
    input:
        transcriptome=config.get(
            "transcriptome-fasta", "resources/ref_transcripts.fasta"
        ),
        genome="resources/ref_genome.fasta",
    output:
        gentrome="indices/salmon/gentrome.fasta",
        decoys="indices/salmon/decoys.txt",
    log:
        "logs/salmon/decoys.log",
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    script:
        "../scripts/salmon_decoy.sh"


rule salmon_index_gentrome:
    """
Generate salmon gentrome index with chromosomes as decoys.

input:
    sequences (str): Path to hybrid genome & transcriptome (gentrome) fasta
        file.
    decoys (str): Path to decoys text file.
output:
    index_files (list): List of salmon index files.
params:
    extra (str): Additional parameters controlling the wrapper execution.
"""
    input:
        sequences="indices/salmon/gentrome.fasta",
        decoys="indices/salmon/decoys.txt",
    output:
        index_files=multiext(
            "indices/salmon/transcriptome_index/",
            "complete_ref_lens.bin",
            "ctable.bin",
            "ctg_offsets.bin",
            "duplicate_clusters.tsv",
            "info.json",
            "mphf.bin",
            "pos.bin",
            "pre_indexing.log",
            "rank.bin",
            "refAccumLengths.bin",
            "ref_indexing.log",
            "reflengths.bin",
            "refseq.bin",
            "seq.bin",
            "versionInfo.json",
        ),
    log:
        "logs/salmon/transcriptome_index.log",
    cache: True
    conda:
        "../envs/salmon.yaml"
    container:
        config["container"].get("salmon")
    threads: 2
    resources:
        mem_mb=32000,
    params:
        # optional parameters
        extra="--gencode",
        outdir=lambda _, output: os.path.dirname(output.index_files[0]),
    shell:
        """
        exec > {log} 2>&1
        salmon index \
        --transcripts {input.sequences} \
        --index {params.outdir} \
        --threads {threads} \
        {params.extra} \
        --decoys {input.decoys}
        """


rule salmon_requant_transcriptome:
    """
Generate transcriptome fasta for salmon requant index that only contains the
sequences that are part of the annotation.

input:
    annotation (str): Path to annotation GTF file.
    fasta (str): Path to reference genome fasta file.
output:
    transcript_fasta (str): Path to filtered transcript fasta file.
params:
    fasta_flag (str): Flag for fasta output.
    extra (str): Additional parameters for the wrapper execution.
"""
    input:
        annotation=config.get("genome-gtf", "resources/ref_annot.gtf"),
        fasta="resources/ref_genome.fasta",
    output:
        transcript_fasta="indices/salmon/requant_index/transcripts.fa",
    log:
        "logs/salmon/requant_transcriptome.log",
    cache: True
    conda:
        "../envs/gffread.yaml"
    container:
        config["container"].get("gffread")
    threads: 1
    resources:
        mem_mb=4000,
    params:
        fasta_flag="-w",
        extra="",
    shell:
        """
        exec > {log} 2>&1
        gffread \
        -w {output.transcript_fasta} \
        -g {input.fasta} {input.annotation}
        """
