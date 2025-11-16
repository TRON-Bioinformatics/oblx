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

awk -v OFS='\t' '{if ($3 == "CDS") print $1, $4, $5, "CDS", $6, $7}' "${snakemake_input[gtf]}" | \
    awk '!dup[$0]++' | \
        bedtools sort > "${snakemake_output[cds_interval]}"