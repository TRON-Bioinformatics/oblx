"""
Snakemake workflow to build required indices.

Make sure to specify a yaml config via --configfile containing the following keys:
* organism: 'human' or 'mouse'
* release: The gencode release (e.g. 45 for human or M35 for mouse)
* genome-build: The genome build name (e.g. GRCh38 for human or GRCm39 for mouse)
* resource-dir: Path to the resources, pulled with pull_resources.smk

@author: Luis Kress (TRON), Johannes Hausmann (TRON)
@version: 20241002
"""
import os
from snakemake.utils import min_version

min_version('8.24.1')

default_build = 'GRCh38'
default_release = '46'
default_organism = 'human'

include: 'rules/common.smk'
include: 'rules/bwa-mem2.smk'
include: 'rules/star.smk'
include: 'rules/faidx.smk'
include: 'rules/genome_masking.smk'
include: 'rules/intervals.smk'
include: 'rules/prepare_ucsc.smk'
include: 'rules/salmon.smk'
include: 'rules/sequence_dict.smk'
include: 'rules/snpeff.smk'
include: 'rules/transcript_annotation.smk'

rule all:
    input:
        get_build_indices_output


rule doc_all:
    input:
        "docs/tronmake-genome-lib-builder/docs/assets/docstring.md",
        "docs/tronmake-genome-lib-builder/docs/assets/software.tsv",

rule docstring_export:
    """
    Export docstrings of snakemake rules into markdown format
    """
    output:
        doctrings_markdown = "docs/tronmake-genome-lib-builder/docs/assets/docstring.md",
    log:
        "docs/tronmake-genome-lib-builder/docs/assets/export_log.txt"
    params:
        rule_collection = {str(rule.name): str(rule.docstring) for rule in workflow.rules}
    conda: 'envs/python.yaml'
    container:
        'docker://tronbioinformatics/tron_data_utils:0.0.1'
    script:
        'scripts/export_doc.py'

rule software_export:
    """
    Export docstrings of snakemake rules into markdown format
    """
    output:
        software_table = "docs/tronmake-genome-lib-builder/docs/assets/software.tsv",
    log:
        "docs/tronmake-genome-lib-builder/docs/assets/export_software_log.txt"
    params:
        software_collection = {str(rule.name): 
            {'conda': str(rule.conda_env), 'container': str(rule.container_img) } for rule in workflow.rules}
    conda: 'envs/python.yaml'
    container:
        'docker://tronbioinformatics/tron_data_utils:0.0.1'
    script:
        'scripts/export_software.py'
