#!/usr/bin/env Rscript

library(GenomicFeatures)
library(rtracklayer)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 7) {
  stop(paste(
    "Usage: annotation2rds.R <gtf> <fasta> <txdb> <twobit_genome>",
    "<serialized_transcripts> <serialized_transcript_ranges>",
    "<serialized_cds> [log_file]"
  ))
}

gtf <- args[1]
fasta <- args[2]
txdb <- args[3]
twobit_genome <- args[4]
serialized_transcripts <- args[5]
serialized_transcript_ranges <- args[6]
serialized_cds <- args[7]

if (length(args) >= 8) {
  log_file <- file(args[8], open = "wt")
  sink(log_file)
  sink(log_file, type = "message")
}

db <- makeTxDbFromGFF(gtf,
  format = "gtf", dataSource = as.character(basename(gtf))
)
saveDb(db, file = txdb)

hg38 <- Biostrings::readDNAStringSet(fasta)
rtracklayer::export.2bit(hg38, twobit_genome)

transcripts <- GenomicFeatures::exonsBy(db, by = c("tx"), use.names = TRUE)
base::saveRDS(transcripts, file = serialized_transcripts)

transcripts_gr <- GenomicFeatures::transcripts(db, columns = c("gene_id", "tx_id", "tx_name"))
base::saveRDS(transcripts_gr, file = serialized_transcript_ranges)

cds <- GenomicFeatures::cdsBy(db, by = c("tx"), use.name = TRUE)
base::saveRDS(cds, file = serialized_cds)
