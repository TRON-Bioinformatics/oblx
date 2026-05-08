#!/usr/bin/env bash

# liftOver does not have a conda release, so we install it from its source. This
# has the advantage of reproducibility when compared to a BiocManager install.
Rscript -e "install.packages('https://www.bioconductor.org/packages/3.23/workflows/src/contrib/liftOver_1.35.0.tar.gz', repos=NULL, type='source')"
Rscript -e "remotes::install_git('https://github.com/TRON-Bioinformatics/splice2neo.git', ref = 'v0.6.14', dependencies=FALSE)"
