#!/usr/bin/env Rscript
library(GenomicFeatures)
library(AnnotationDbi)
library(readr)
library(magrittr)

log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file)
sink(log_file, type = "message")

gtf <- snakemake@input[["gtf"]]
tx2gene <- snakemake@output[["tx2gene"]]

txdb <- makeTxDbFromGFF(gtf)
k <- keys(txdb, keytype = "TXNAME")
df <- AnnotationDbi::select(txdb, k, "GENEID", "TXNAME")
df %>% readr::write_tsv(tx2gene)
