#!/usr/bin/env Rscript
library(GenomicFeatures)
library(AnnotationDbi)
library(readr)
library(magrittr)

gtf <- snakemake@input[["gtf"]]
tx2gene <- snakemake@output[["tx2gene"]]

txdb <- makeTxDbFromGFF(gtf)
k <- keys(txdb, keytype = "TXNAME")
df <- AnnotationDbi::select(txdb, k, "GENEID", "TXNAME")
df %>% readr::write_tsv(tx2gene)
