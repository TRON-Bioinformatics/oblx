rule annotation_R:
    """Prepare annotation for R

    Rule to prepare annotation data for splice2neo.
    This rule creates a TxDb (sqlite) database of 
    the reference transcript annotation and a 2Bit 
    representation of the genomic fasta file.

    input:
        fasta (string): Path to DNA fasta file
        gtf (string): Path to GTF file
    output:
        txdb (string): Path to TxDb sqlite database
        twoBitGenome(string): Path to 2Bit DNA file
    """
    input:
        fasta = 'resources/ref_genome.fasta',
        gtf = 'resources/ref_annot.gtf',
    output:
        txdb =
            'indices/R/ref_annot_txdb.sqlite',
        twobit_genome =
            'indices/R/ref_genome.2bit',
        serialized_transcripts =
            'indices/R/ref_transcripts.Rds',
        serialized_transcript_ranges =
            'indices/R/ref_transcript_ranges.Rds',
        serialized_cds =
            'indices/R/ref_cds.Rds'
    conda:
        '../envs/renv.yaml'
    resources:
        mem_mb = 32000
    benchmark:
        'benchmarks/annotation_R.txt'
    script:
        '../scripts/annotation2rds.R'
