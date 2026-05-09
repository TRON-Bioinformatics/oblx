#!/usr/bin/env bash
#
# Generate allele frequency (AF) only VCF file required by MuTect2
#
# Usage: make_AF_only_gnomad_vcf.sh <gnomad_vcf> <min_af> <vcf_header> <out_vcf> [log_file]

set -euo pipefail

if [[ $# -lt 4 ]]; then
    echo "Usage: $0 <gnomad_vcf> <min_af> <vcf_header> <out_vcf> [log_file]" >&2
    exit 1
fi

gnomad_vcf="$1"
min_af="$2"
vcf_header="$3"
out_vcf="$4"

if [[ $# -ge 5 ]]; then
    exec >"$5" 2>&1
fi

tmp_vcf="$(mktemp)"

trap 'rm -f -- "$tmp_vcf"' EXIT

bcftools query \
    -i "AF>${min_af} & FILTER == 'PASS'" \
    -f '%CHROM\t%POS\t%ID\t%REF\t%ALT\t%QUAL\t%FILTER\tAF=%INFO/AF\n' \
    --output $tmp_vcf $gnomad_vcf

cat $vcf_header $tmp_vcf | bgzip -c >$out_vcf

tabix -p vcf $out_vcf
