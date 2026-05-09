#!/usr/bin/env bash
#
# SnakeMake wrapper script to variants for contamination
# calculation with GATK's PileupSummaries
#
# Selects for variants with the following properties:
# * biallelic
# * on chromosome 1
# * allele frequency > 5
# * filter: PASS
#
# @Author: Luis Kress, Johannes Hausmann
# @Date: 2024-11-08
# @Copyright: Copyright 2024, TRON gGmbH, Mainz, Germany
# @License: MIT
# @Version: 0.0.1
# @Status: Development

set -euo pipefail

exec >"${snakemake_log[0]}" 2>&1

input_vcf="${snakemake_input[vcf_chr1]}"
vcf_header="${snakemake_input[minimal_gnomad_header]}"
out_vcf="${snakemake_output[prep_vcf]}"

tmp_vcf="$(mktemp)"

bcftools view \
    --max-alleles 2 \
    --regions chr1 \
    $input_vcf |
    bcftools query \
        -i "AF > 0.05 & FILTER == 'PASS'" \
        -f '%CHROM\t%POS\t%ID\t%REF\t%ALT\t%QUAL\t%FILTER\tAF=%INFO/AF\n' \
        --output $tmp_vcf -

cat $vcf_header $tmp_vcf | bgzip -c >$out_vcf

tabix -p vcf $out_vcf

rm $tmp_vcf
