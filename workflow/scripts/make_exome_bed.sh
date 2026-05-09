#!/usr/bin/env bash
#
# SnakeMake wrapper script to generate exome interval file based
# on GENCODE basic transcript definition

set -euo pipefail

TMPDIR="$(mktemp -d)"
trap 'rm -rf -- "$TMPDIR"' EXIT

exec 2>"${snakemake_log[0]}"

TX_TAG="${snakemake_params[exome_transcript_definition]}"

# Succeed even when no exons are found in the grep step.
awk '{if ($3 == "exon") print $0}' "${snakemake_input[gtf]}" |
    { grep "tag \"${TX_TAG}\"" || [[ $? -eq 1 ]]; } |
    bedtools sort |
    bedtools merge >"${TMPDIR}"/tmp.bed

bedtools slop \
    -i "${TMPDIR}"/tmp.bed \
    -g "${snakemake_input[chrom_sizes]}" \
    -b "${snakemake_params[intron_slop]}" | bedtools merge >"${snakemake_output[exome_interval]}"
