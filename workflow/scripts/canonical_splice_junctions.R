#!/usr/bin/env Rscript

library(GenomicFeatures)
library(readr)
library(tibble)
library(magrittr)
library(splice2neo)

gtf <- snakemake@input[['gtf']]
canonical_juncs <- snakemake@output[['canonical_juncs']]

ref_juncs <- splice2neo::canonical_junctions(splice2neo::parse_gtf(gtf))
ref_juncs <- tibble(junc_id=ref_juncs)
ref_juncs %>% readr::write_tsv(canonical_juncs)