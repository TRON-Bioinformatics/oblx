#!/usr/bin/env Rscript

library(GenomicFeatures)
library(readr)
library(tibble)
library(magrittr)
library(splice2neo)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Usage: canonical_splice_junctions.R <gtf> <canonical_juncs> [log_file]")
}

gtf <- args[1]
canonical_juncs <- args[2]

if (length(args) >= 3) {
  log_file <- file(args[3], open = "wt")
  sink(log_file)
  sink(log_file, type = "message")
}

ref_juncs <- splice2neo::canonical_junctions(splice2neo::parse_gtf(gtf))
ref_juncs <- tibble(junc_id = ref_juncs)
ref_juncs %>% readr::write_tsv(canonical_juncs)
