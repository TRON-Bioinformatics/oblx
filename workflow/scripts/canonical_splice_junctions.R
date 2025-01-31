#!/usr/bin/env Rscript

library(GenomicFeatures)
library(tidyverse)
library(splice2neo)

gtf <- snakemake@input[['gtf']]
canonical_juncs <- snakemake@output[['canonical_juncs']]

canonical_juncs <- splice2neo::canonical_junctions(splice2neo::parse_gtf(gtf))
canonical_juncs <- tibble(junc_id=canonical_juncs)
canonical_juncs %>% readr::write_tsv(canonical_juncs)