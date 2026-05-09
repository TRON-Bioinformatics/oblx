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

# Horrible hack that is necessary because there's currently no functional
# container image for splice2neo>0.6.13 (the first version using txdbmaker),
# while at the same time the current renv conda env can't be solved when
# including GenomicFeatures<1.61.1 (the first version to remove the
# `makeTxDbFromGFF` function).
# Once <https://github.com/TRON-bioinformatics/splice2neo/issues/6> is resolved,
# the container splice2neo should be updated and only txdbmaker should be used.
makeTxDbFromGFF <- if (length(find.package("txdbmaker", quiet = TRUE)) > 0) {
  txdbmaker::makeTxDbFromGFF
} else {
  # We have to assume the function comes from GenomicFeatures.
  GenomicFeatures::makeTxDbFromGFF
}

txdb <- makeTxDbFromGFF(gtf)
k <- keys(txdb, keytype = "TXNAME")
df <- AnnotationDbi::select(txdb, k, "GENEID", "TXNAME")
df %>% readr::write_tsv(tx2gene)
