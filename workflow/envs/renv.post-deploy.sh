#!/usr/bin/env bash

set -euo pipefail

Rscript -e "remotes::install_git('https://github.com/TRON-Bioinformatics/splice2neo.git', ref = 'v0.6.13', dependencies=FALSE)"
