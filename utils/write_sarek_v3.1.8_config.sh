#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./write_sarek_tron_config.sh /path/to/tronmake/resources /path/to/output/nextflow.config
#
# Example TRON genome lib paths are based on tronmake-genome-lib-builder outputs:
#   ref_genome.fasta
#   ref_genome.fasta.fai
#   ref_genome.dict
#   (and optional annotation/resource files if you have them)

TRON_RESOURCES_DIR="${1:-}"
OUT_CONFIG="${2:-nextflow.config}"

if [[ -z "${TRON_RESOURCES_DIR}" ]]; then
  echo "Usage: $0 /path/to/tronmake/resources [/path/to/output/nextflow.config]" >&2
  exit 1
fi

cat > "${OUT_CONFIG}" <<EOF
params {
    // Sarek input/output
    genome      = 'TRON_CUSTOM'
    outdir      = './results'
    tools       = 'mutect2,strelka2,freebayes'

    // Point Sarek at the TRON-generated reference
    fasta       = '${TRON_RESOURCES_DIR}/ref_genome.fasta'
    fai         = '${TRON_RESOURCES_DIR}/ref_genome.fasta.fai'
    dict        = '${TRON_RESOURCES_DIR}/ref_genome.dict'

    // Keep Sarek on the three requested callers only
    // (Mutect2 is somatic, Strelka2 and FreeBayes can be used as configured by Sarek)
    joint_mutect2 = false
    only_paired_variant_calling = false

    
    dbsnp                 = '${TRON_RESOURCES_DIR}/resources/gatk_bundle/Homo_sapiens_assembly38.dbsnp138.vcf.gz'
    dbsnp_tbi             = '${TRON_RESOURCES_DIR}/resources/gatk_bundle/Homo_sapiens_assembly38.dbsnp138.vcf.gz.tbi'
    known_indels          = '${TRON_RESOURCES_DIR}/resources/gatk_bundle/Homo_sapiens_assembly38.known_indels.vcf.gz'
    known_indels_tbi      = '${TRON_RESOURCES_DIR}/resources/gatk_bundle/Homo_sapiens_assembly38.known_indels.vcf.gz.tbi'
    mills                 = '${TRON_RESOURCES_DIR}/resources/gatk_bundle/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz'
    mills_tbi             = '${TRON_RESOURCES_DIR}/resources/gatk_bundle/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi'
    // snpeff_db             = '...'
    // snpsift_db            = '...'
}

profiles {
    tron {
        // Choose your execution backend here, e.g. docker / singularity / conda
        // Example:
        apptainer.enabled = true
    }
}

process {
    // Optional: make the config more explicit/stable for these callers
    withName: '.*MUTECT2.*' {
        ext.args = ''
    }
    withName: '.*STRELKA.*' {
        ext.args = ''
    }
    withName: '.*FREEBAYES.*' {
        ext.args = ''
    }
}
EOF

echo "Wrote ${OUT_CONFIG}"
