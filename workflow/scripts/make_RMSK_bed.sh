#!/usr/bin/env bash
#
# SnakeMake wrapper script to generate BED file of UCSC RepeatMasker dump
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

zcat "${snakemake_input[rmsk]}" | \
    awk -v OFS="\t" '{print $6, $7-1, $8, $11, $2, $10}' > "${TMPDIR}"/tmp.bed

bedtools merge -s -c 4,5,6 -o distinct,distinct,distinct < "${TMPDIR}"/tmp.bed > "${snakemake_output[rmsk_bed]}"