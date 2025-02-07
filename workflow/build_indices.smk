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

min_version('8.5.4')

default_build = 'GRCh38'
default_release = '46'
default_organism = 'human'

include: 'rules/common.smk'
include: 'rules/bwa-mem2.smk'
include: 'rules/star.smk'
include: 'rules/salmon.smk'
include: 'rules/kallisto.smk'
include: 'rules/sequence_dict.smk'
include: 'rules/snpeff.smk'
include: 'rules/transcript_annotation.smk'

onstart:
    # write the config to the output directory for reproducibility
    if not os.path.exists('configs'):
        os.mkdir('configs')
    with open(f'configs/{timestamp}_build_indices_config.yaml', 'w') as configfile:
        yaml.dump(config, configfile, default_flow_style=False)

rule all:
    input:
        get_build_indices_output



