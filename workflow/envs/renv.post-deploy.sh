#!/bin/bash
Rscript -e "install.packages('remotes', repos='http://cran.us.r-project.org')"
Rscript -e "remotes::install_version('MASS', '7.3-60.0.1', repos='http://cran.us.r-project.org')"
Rscript -e "remotes::install_version('Matrix', '1.6-5', repos='http://cran.us.r-project.org')"
Rscript -e "if (!requireNamespace('BiocManager', quietly=TRUE)) install.packages('BiocManager'); BiocManager::install('GenomicFeatures', ask=FALSE, update=FALSE)"
Rscript -e "remotes::install_git('https://github.com/TRON-Bioinformatics/splice2neo.git', ref = 'v0.6.12', Ncpus=8)"
