#!/usr/bin/env bash
#
# Script to generate CDS interval file based on GTF annotation
# Usage: make_cds_bed.sh <gtf> <cds_interval>

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <gtf> <cds_interval>" >&2
    exit 1
fi

gtf="$1"
cds_interval="$2"

awk -v OFS='\t' '{if ($3 == "CDS") print $1, $4, $5, "CDS", $6, $7}' "${gtf}" |
    awk '!dup[$0]++' |
    bedtools sort >"${cds_interval}"
