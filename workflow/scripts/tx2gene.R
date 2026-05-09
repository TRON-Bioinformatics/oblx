#!/usr/bin/env Rscript
library(GenomicFeatures)
library(AnnotationDbi)
library(readr)
library(magrittr)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Usage: tx2gene.R <gtf> <tx2gene> [log_file]")
}

gtf <- args[1]
tx2gene <- args[2]

if (length(args) >= 3) {
  log_file <- file(args[3], open = "wt")
  sink(log_file)
  sink(log_file, type = "message")
}

txdb <- makeTxDbFromGFF(gtf)
k <- keys(txdb, keytype = "TXNAME")
df <- AnnotationDbi::select(txdb, k, "GENEID", "TXNAME")
df %>% readr::write_tsv(tx2gene)
