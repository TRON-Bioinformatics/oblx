#!/usr/bin/env Rscript

library(GenomicFeatures)
library(rtracklayer)

gtf <- snakemake@input[['gtf']]
fasta <- snakemake@input[['fasta']]
txdb <- snakemake@output[['txdb']]
twobit_genome <- snakemake@output[['twobit_genome']]
serialized_transcripts <- snakemake@output[['serialized_transcripts']]
serialized_transcript_ranges <- snakemake@output[['serialized_transcript_ranges']]
serialized_cds <- snakemake@output[['serialized_cds']]

db <- makeTxDbFromGFF(gtf, 
    format="gtf", dataSource=as.character(basename(gtf)))
saveDb(db, file=txdb)

hg38 <- Biostrings::readDNAStringSet(fasta)  
rtracklayer::export.2bit(hg38, twobit_genome) 

transcripts <- GenomicFeatures::exonsBy(db, by = c("tx"), use.names = TRUE)
base::saveRDS(transcripts, file=serialized_transcripts)

transcripts_gr <- GenomicFeatures::transcripts(db, columns = c("gene_id", "tx_id", "tx_name"))
base::saveRDS(transcripts_gr, file=serialized_transcript_ranges)

cds <- GenomicFeatures::cdsBy(db, by = c("tx"), use.name = TRUE)
base::saveRDS(cds, file=serialized_cds)