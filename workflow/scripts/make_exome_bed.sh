#!/usr/bin/env bash
#
# SnakeMake wrapper script to generate exome interval file based 
# on GENCODE basic transcript definition
#
# @Author: Johannes Hausmann, Luis Kress
# @Date: 2024-11-01
# @Copyright: Copyright 2024, TRON gGmbH, Mainz, Germany
# @License: MIT
# @Version: 0.0.1
# @Status: Development

TMPDIR="$(mktemp -d)"
trap 'rm -rf -- "$TMPDIR"' EXIT

exec 2> "${snakemake_log[0]}"

TX_TAG="${snakemake_params[exome_transcript_definition]}"

awk '{if ($3 == "exon") print $0}' "${snakemake_input[gtf]}" | \
    grep "tag \"${TX_TAG}\"" | \
        bedtools sort | \
            bedtools merge > "${TMPDIR}"/tmp.bed

bedtools slop \
    -i "${TMPDIR}"/tmp.bed \
    -g "${snakemake_input[chrom_sizes]}" \
    -b "${snakemake_params[intron_slop]}" | bedtools merge > "${snakemake_output[exome_interval]}"