#!/usr/bin/env bash
#
# Prepare variants for contamination calculation with GATK's PileupSummaries
#
# Selects for variants with the following properties:
# * biallelic
# * on chromosome 1
# * allele frequency > 5
# * filter: PASS
#
# Usage: prepare_variants_for_contamination.sh <vcf_chr1> <vcf_header> <out_vcf>

set -euo pipefail

if [[ $# -lt 3 ]]; then
    echo "Usage: $0 <vcf_chr1> <vcf_header> <out_vcf>" >&2
    exit 1
fi

input_vcf="$1"
vcf_header="$2"
out_vcf="$3"

tmp_vcf="$(mktemp)"

trap 'rm -f -- "$tmp_vcf"' EXIT

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
