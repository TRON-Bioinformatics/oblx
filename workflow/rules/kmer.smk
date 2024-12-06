rule jellyfish_count_genome:
    input:
        'resources/ref_genome.fasta',
    output:
        f'indices/kmer/ref_genome_k{config.get('kmer_size', 21)}.jf',
    params:
        kmer_length = config.get('kmer_size', 21),
        size = "3G",
        extra = "--canonical",
    threads: 4
    wrapper:
        "v5.2.1/bio/jellyfish/count"

rule jellyfish_count_transcripts:
    input:
        config.get(
            'transcriptome-fasta', 'resources/ref_transcripts.fasta'
        ),
    output:
        f'indices/kmer/ref_transcripts_k{config.get('kmer_size', 21)}.jf',
    params:
        kmer_length = config.get('kmer_size', 21),
        size = "1G",
        extra = "--canonical",
    threads: 4
    wrapper:
        "v5.2.1/bio/jellyfish/count"