rule kallisto_index:
    input:
        fasta = 'resources/ref_transcripts.fasta'
    output:
        index = "indices/kallisto/ref_transcript.idx",
    params:
        extra="",
    log:
        "logs/kallisto_index.log",
    threads: 2
    wrapper:
        "v5.0.0/bio/kallisto/index"
