"""
Snakemake workflow to build required indices.

Make sure to specify a yaml config via --configfile containing the following keys:
* organism: 'human' or 'mouse'
* release: The gencode release (e.g. 45 for human or M35 for mouse)
* genome_build: The genome build name (e.g. GRCh38 for human or GRCm39 for mouse)
* resource-dir: Path to the resources, pulled with pull_resources.smk

@author: Luis Kress (TRON), Johannes Hausmann (TRON)
@version: 20241002
"""


rule build_indices:
    input:
        get_build_indices_output,
