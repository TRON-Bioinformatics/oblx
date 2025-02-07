rule salmon_decoy:
    """
    Generate salmon decoys.
    """
    input:
        transcriptome = config.get(
            'transcriptome-fasta', 'resources/ref_transcripts.fasta'
        ),
        genome = 'resources/ref_genome.fasta'
    output:
        gentrome = 'indices/salmon/gentrome.fasta',
        decoys = 'indices/salmon/decoys.txt',
    threads: 2
    log:
        'decoys.log'
    wrapper:
        "v4.7.1/bio/salmon/decoys"

rule salmon_index_gentrome:
    """
    Generate salmon gentrome index with chromosomes as decoys.
    """
    input:
        sequences = 'indices/salmon/gentrome.fasta',
        decoys = 'indices/salmon/decoys.txt',
    output:
        multiext(
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
    cache: True
    log:
        "logs/salmon/transcriptome_index.log",
    threads: 2
    resources:
        mem_mb = 32000
    params:
        # optional parameters
        extra="--gencode",
    wrapper:
        "v4.7.1/bio/salmon/index"

