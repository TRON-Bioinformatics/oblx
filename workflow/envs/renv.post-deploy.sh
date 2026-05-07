#!/bin/bash
Rscript -e "remotes::install_git('https://github.com/TRON-Bioinformatics/splice2neo.git', ref = 'v0.6.12', dependencies=FALSE, Ncpus=8)"
