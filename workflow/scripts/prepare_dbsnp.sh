#!/usr/bin/env bash
#
# Prepare dbSNP VCF for genome lib
#
# Usage: prepare_dbsnp.sh <chrom_mapping> <vcf> <outdir> <dbsnp_vcf>

set -euo pipefail

if [[ $# -lt 4 ]]; then
    echo "Usage: $0 <chrom_mapping> <vcf> <outdir> <dbsnp_vcf>" >&2
    exit 1
fi

chrom_mapping="$1"
vcf="$2"
outdir="$3"
dbsnp_vcf="$4"

CHROMOSOMES="$(echo {1..22} | tr ' ' ',')"
CHROMOSOMES="${CHROMOSOMES},X,Y"

TMPDIR="$(mktemp -d -p "${outdir}")"

trap 'rm -rf -- "$TMPDIR"' EXIT

bcftools view --regions "$CHROMOSOMES" "${vcf}" |
    bcftools annotate --rename-chrs "${chrom_mapping}" | bgzip -c >"${dbsnp_vcf}"

tabix -p vcf "${dbsnp_vcf}"
