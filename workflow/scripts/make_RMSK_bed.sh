#!/usr/bin/env bash
#
# Generate BED file of UCSC RepeatMasker dump
#
# Usage: make_RMSK_bed.sh <rmsk_gz> <rmsk_bed> [log_file]

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <rmsk_gz> <rmsk_bed> [log_file]" >&2
    exit 1
fi

rmsk="$1"
rmsk_bed="$2"

TMPDIR="$(mktemp -d)"
trap 'rm -rf -- "$TMPDIR"' EXIT

if [[ $# -ge 3 ]]; then
    exec 2>"$3"
fi

# the entries are filtered for std chroms only (regex) as positions on scaffolds can be -1 leading to bedtools error
zcat "${rmsk}" |
    awk -v OFS="\t" '$6 ~ /chr([[:digit:]]|X|Y|M)+$/ {print $6, $7-1, $8, $11, $2, $10}' >"${TMPDIR}"/tmp.bed

bedtools merge -s -c 4,5,6 -o distinct,distinct,distinct <"${TMPDIR}"/tmp.bed >"${rmsk_bed}"
