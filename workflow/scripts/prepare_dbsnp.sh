#!/usr/bin/env bash
#
# Prepare dbSNP VCF for genome lib
#
# Usage: prepare_dbsnp.sh <chrom_mapping> <vcf> <dbsnp_vcf>

set -euo pipefail

if [[ $# -lt 3 ]]; then
    echo "Usage: $0 <chrom_mapping> <vcf> <dbsnp_vcf>" >&2
    exit 1
fi

chrom_mapping="$1"
vcf="$2"
dbsnp_vcf="$3"

CHROMOSOMES="$(echo {1..22} | tr ' ' ',')"
CHROMOSOMES="${CHROMOSOMES},X,Y"

bcftools view --regions "$CHROMOSOMES" "${vcf}" |
    bcftools annotate --rename-chrs "${chrom_mapping}" | bgzip -c >"${dbsnp_vcf}"

tabix -p vcf "${dbsnp_vcf}"
