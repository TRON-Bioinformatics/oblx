#!/usr/bin/env Rscript
library(GenomicFeatures)
library(tidyverse)

gtf <- snakemake@input[['gtf']]
tx2gene <- snakemake@output[['tx2gene']]

txdb <- makeTxDbFromGFF(gtf)
k <- keys(txdb, keytype = "TXNAME")
tx2gene <- AnnotationDbi::select(txdb, k, "GENEID", "TXNAME")
tx2gene %>% readr::write_tsv(tx2gene)