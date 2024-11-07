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
            'resources/ref_genome.2bit',
        serialized_transcripts =
            'resources/R/ref_transcripts.Rds',
        serialized_transcript_ranges =
            'resources/R/ref_transcript_ranges_reliable.Rds',
        serialized_cds =
            'resources/R/ref_cds_reliable.Rds'
    conda:
        'envs/splice2neo.yaml'
    shell:
        '''
        R --no-save <<__EOF__
        library(GenomicFeatures)
        library(rtracklayer)

        db <- makeTxDbFromGFF("{input.gtf}", format="gtf", dataSource=as.character("{input.gtf}"))
        saveDb(db, file="{output.txdb}")

        hg38 <- Biostrings::readDNAStringSet("{input.fasta}")  
        rtracklayer::export.2bit(hg38, "{output.twobit_genome}")  

        transcripts <- GenomicFeatures::exonsBy(db, by = c("tx"), use.names = TRUE)
        base::saveRDS(transcripts, file="{output.serialized_transcripts}")

        transcripts_gr <- GenomicFeatures::transcripts(db, columns = c("gene_id", "tx_id", "tx_name"))
        base::saveRDS(transcripts_gr, file="{output.serialized_transcript_ranges}")

        cds <- GenomicFeatures::cdsBy(db, by = c("tx"), use.name = TRUE)
        base::saveRDS(cds, file="{output.serialized_cds}")
        '''

rule transcript_to_gene_mapping:
    input:
        gtf = 'resources/ref_annot.gtf'
    output:
        tx2gene = 'resources/ref_annot_transcript2gene.tsv'
    conda:
        'envs/splice2neo.yaml'
    shell:
        '''
        R --no-save <<__EOF__
        library(GenomicFeatures)
        library(tidyverse)
        txdb <- makeTxDbFromGFF("{input.gtf}")
        k <- keys(txdb, keytype = "TXNAME")
        tx2gene <- AnnotationDbi::select(txdb, k, "GENEID", "TXNAME")
        tx2gene %>% readr::write_tsv("{output.tx2gene}")
        __EOF__
        '''

rule gene_to_hgnc_mapping:
    input:
        gtf = 'resources/ref_annot.gtf'
    output:
        mapping_table = 'resources/ref_annot_gene2hgnc.tsv'
    conda:
        'envs/python.yaml'
    script:
        'scripts/get_annotation_data.py'

rule canonical_junction_list:
    input:
        gtf = 'resources/ref_annot.gtf'
    output:
        canonical_juncs = 'resources/ref_annot_splice_sites.tsv'
    conda:
        'envs/splice2neo.yaml'
    shell:
        '''
        R --no-save <<__EOF__
        library(GenomicFeatures)
        library(tidyverse)
        library(splice2neo)
        canonical_juncs <- splice2neo::canonical_junctions(splice2neo::parse_gtf("{input.gtf})")
        canonical_juncs <- tibble(junc_id=canonical_juncs)
        canonical_juncs %>% readr::write_tsv("{output.canonical_juncs}")
        __EOF__
        '''

