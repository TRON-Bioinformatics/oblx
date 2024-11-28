#!/usr/bin/env bash
#
# SnakeMake wrapper script to generate allele frequency (AF)
# only VCF file required by MuTect2
#
# @Author: Johannes Hausmann, Luis Kress
# @Date: 2024-11-01
# @Copyright: Copyright 2024, TRON gGmbH, Mainz, Germany
# @License: MIT
# @Version: 0.0.1
# @Status: Development

gnomad_vcf="${snakemake_input[gnomad]}"
min_af=${snakemake_params[minimum_allele_frequency]}
vcf_header="${snakemake_input[minimal_gnomad_header]}"
tmp_vcf="${snakemake_params[tmp_vcf]}"
out_vcf="${snakemake_output[vcf_file]}"

bcftools query \
    -i "AF>${min_af} & FILTER == 'PASS'" \
    -f '%CHROM\t%POS\t%ID\t%REF\t%ALT\t%QUAL\t%FILTER\tAF=%INFO/AF\n' \
    --output $tmp_vcf $gnomad_vcf

cat $vcf_header $tmp_vcf | bgzip -c > $out_vcf

tabix -p vcf $out_vcf

rm $tmp_vcf
