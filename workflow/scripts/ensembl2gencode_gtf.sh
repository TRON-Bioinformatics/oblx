#!/usr/bin/env bash
#
# Rename Ensembl chromosome names to GENCODE "chr" convention
#
# Usage: ensembl2gencode_gtf.sh <gtf> <renamed_gtf>

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <gtf> <renamed_gtf>" >&2
    exit 1
fi

gtf="$1"
renamed_gtf="$2"

awk 'BEGIN{FS=OFS="\t"} \
    $1=="MT" {$1="chrM"; print; next} \
    $1 ~ /^([0-9]+|X|Y)$/ {$1="chr"$1} \
    {print}' "${gtf}" >"${renamed_gtf}"
