#!/usr/bin/env Rscript

library(GenomicFeatures)
library(readr)
library(tibble)
library(magrittr)
library(splice2neo)

log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file)
sink(log_file, type = "message")

gtf <- snakemake@input[["gtf"]]
canonical_juncs <- snakemake@output[["canonical_juncs"]]

ref_juncs <- splice2neo::canonical_junctions(splice2neo::parse_gtf(gtf))
ref_juncs <- tibble(junc_id = ref_juncs)
ref_juncs %>% readr::write_tsv(canonical_juncs)
