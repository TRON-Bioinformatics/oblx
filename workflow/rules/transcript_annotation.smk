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
            'resources/R/ref_annot_txdb.sqlite',
        twobit_genome =
            'resources/R/ref_genome.2bit',
        serialized_transcripts =
            'resources/R/ref_transcripts.Rds',
        serialized_transcript_ranges =
            'resources/R/ref_transcript_ranges.Rds',
        serialized_cds =
            'resources/R/ref_cds.Rds'
    conda:
        '../envs/renv.yaml'
    resources:
        mem_mb = 32000
    benchmark:
        'benchmarks/annotation_R.txt'
    script:
        '../scripts/annotation2rds.R'

rule transcript_to_gene_mapping:
    input:
        gtf = 'resources/ref_annot.gtf'
    output:
        tx2gene = 'resources/ref_annot_transcript2gene.tsv'
    conda:
        '../envs/renv.yaml'
    script:
        '../scripts/tx2gene.R'

rule gene_to_hgnc_mapping:
    input:
        gtf = 'resources/ref_annot.gtf'
    output:
        mapping_table = 'resources/ref_annot_gene2hgnc.tsv'
    conda:
        '../envs/python.yaml'
    script:
        '../scripts/get_annotation_data.py'

rule canonical_junction_list:
    input:
        gtf = 'resources/ref_annot.gtf'
    output:
        canonical_juncs = 'resources/splicing/ref_annot_splice_sites.tsv'
    conda:
        '../envs/renv.yaml'
    script:
        '../scripts/canonical_splice_junctions.R'

