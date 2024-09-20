rule filter_for_reliable_transcripts:
    """
    Filter GENCODE GTF for reliable transcripts models. 
    Remove transcripts without sufficient TSL or protein evidence
    """
    input:
        gtf = rules.gunzip_annotation_data.output.gtf,
        swissprot_map = rules.gunzip_annotation_data.output.swissprot_map,
        trembl_map = rules.gunzip_annotation_data.output.trembl_map,
        uniprot = workflow.source_path('../GenomeData/uniprot_download_9606_2024_06_06.tsv.gz')
    output:
        reliable_transcripts = 'resources/splicing/ref_annot_reliable_transcripts.tsv'
    conda:
        'envs/tsl_filter.yaml'
    params:
        exe = workflow.source_path('tools/filter_transcripts.py'),
        tsl_levels = " ".join(config.get('tsl_level', ["1","2", "3"]))
    shell:
        'python {params.exe} '
        '--gtf {input.gtf} '
        '--output {output.reliable_transcripts} '
        '--swissprot-map {input.swissprot_map} '
        '--trembl-map {input.trembl_map} '
        '--uniprot-annot {input.uniprot} '
        '--tsl {params.tsl_levels}'

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
        fasta = rules.gunzip_annotation_data.output.fasta,
        gtf = rules.gunzip_annotation_data.output.gtf,
        reliable_transcripts = rules.filter_for_reliable_transcripts.output.reliable_transcripts
    params:
        exe = workflow.source_path('tools/gtf_to_txdb.R')
    output:
        txdb =
            'resources/splicing/ref_annot_txdb.sqlite',
        twobit_genome =
            'resources/splicing/ref_genome.2bit',
        serialized_transcripts =
            'resources/splicing/ref_transcripts_reliable.Rds',
        serialized_transcript_ranges =
            'resources/splicing/ref_transcript_ranges_reliable.Rds',
        serialized_cds =
            'resources/splicing/ref_cds_reliable.Rds'
    conda:
        'envs/splice2neo.yaml'
    shell:
        'Rscript '
        '--vanilla {params.exe} '
        '--gtf_input {input.gtf} '
        '--dna_input {input.fasta} '
        '--reliable_transcripts {input.reliable_transcripts} '
        '--output_db {output.txdb} '
        '--output_2bit {output.twobit_genome} '
        '--output_cds_rds {output.serialized_cds} '
        '--output_tx_rds {output.serialized_transcripts} '
        '--output_tx_ranges_rds {output.serialized_transcript_ranges} '

rule transcript_to_gene_mapping:
    input:
        gtf = rules.gunzip_annotation_data.output.gtf
    output:
        tx2gene = 'resources/splicing/tx2gene.tsv'
    conda:
        'envs/splice2neo.yaml'
    shell:
        '''
        R --no-save <<__EOF__
        library(GenomicFeatures)
        library(tidyverse)
        txdb <- makeTxDbFromGFF({input.gtf})
        k <- keys(txdb, keytype = "TXNAME")
        tx2gene <- AnnotationDbi::select(txdb, k, "GENEID", "TXNAME")
        tx2gene %>% readr::write_tsv({output.tx2gene})
        __EOF__
        '''

rule canonical_junction_list:
    input:
        gtf = rules.gunzip_annotation_data.output.gtf
    output:
        canonical_juncs = 'resources/splicing/canonical_junctions.tsv'
    conda:
        'envs/splice2neo.yaml'
    shell:
        '''
        R --no-save <<__EOF__
        
        library(GenomicFeatures)
        library(tidyverse)
        library(splice2neo)
        canonical_juncs <- splice2neo::canonical_junctions(splice2neo::parse_gtf({input.gtf}))
        canonical_juncs <- tibble(junc_id=canonical_juncs)
        canonical_juncs %>% readr::write_tsv({output.canonical_juncs})
        __EOF__
        '''

