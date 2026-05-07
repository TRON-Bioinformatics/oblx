#!/usr/bin/env bash
#
# SnakeMake wrapper script to prepare dbSNP VCF for genome lib
#
# @Author: Johannes Hausmann, Luis Kress
# @Date: 2024-11-01
# @Copyright: Copyright 2024, TRON gGmbH, Mainz, Germany
# @License: MIT
# @Version: 0.0.1
# @Status: Development

set -eo pipefail

CHROMOSOMES="$(echo {1..22} | tr ' ' ',')"
CHROMOSOMES="${CHROMOSOMES},X,Y"

TMPDIR="$(mktemp -d -p ${snakemake_params[outdir]})"

trap 'rm -rf -- "$TMPDIR"' EXIT

exec 2>"${snakemake_log[0]}"

bcftools view --regions "$CHROMOSOMES" "${snakemake_input[vcf]}" |
    bcftools annotate --rename-chrs "${snakemake_input[chrom_mapping]}" | bgzip -c >"${snakemake_output[dbsnp_vcf]}"

tabix -p vcf "${snakemake_output[dbsnp_vcf]}"
