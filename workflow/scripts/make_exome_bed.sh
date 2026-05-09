#!/usr/bin/env bash
#
# Generate exome interval file based on GENCODE basic transcript definition
#
# Usage: make_exome_bed.sh <gtf> <chrom_sizes> <tx_tag> <intron_slop> <exome_interval>

set -euo pipefail

if [[ $# -lt 5 ]]; then
    echo "Usage: $0 <gtf> <chrom_sizes> <tx_tag> <intron_slop> <exome_interval>" >&2
    exit 1
fi

gtf="$1"
chrom_sizes="$2"
TX_TAG="$3"
intron_slop="$4"
exome_interval="$5"

TMPDIR="$(mktemp -d)"
trap 'rm -rf -- "$TMPDIR"' EXIT

# Succeed even when no exons are found in the grep step.
awk '{if ($3 == "exon") print $0}' "${gtf}" |
    { grep "tag \"${TX_TAG}\"" || [[ $? -eq 1 ]]; } |
    bedtools sort |
    bedtools merge >"${TMPDIR}"/tmp.bed

bedtools slop \
    -i "${TMPDIR}"/tmp.bed \
    -g "${chrom_sizes}" \
    -b "${intron_slop}" | bedtools merge >"${exome_interval}"
