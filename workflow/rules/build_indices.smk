"""
Snakemake workflow to build required indices.

@author: Luis Kress (TRON), Johannes Hausmann (TRON)
@version: 20241002
"""


rule build_indices:
    input:
        get_build_indices_output,
