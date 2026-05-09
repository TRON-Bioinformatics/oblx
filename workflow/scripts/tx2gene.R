#!/usr/bin/env Rscript
library(GenomicFeatures)
library(AnnotationDbi)
library(readr)
library(magrittr)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Usage: tx2gene.R <gtf> <tx2gene>")
}

gtf <- args[1]
tx2gene <- args[2]

txdb <- makeTxDbFromGFF(gtf)
k <- keys(txdb, keytype = "TXNAME")
df <- AnnotationDbi::select(txdb, k, "GENEID", "TXNAME")
df %>% readr::write_tsv(tx2gene)
