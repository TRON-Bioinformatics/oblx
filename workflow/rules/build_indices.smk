"""
Snakemake workflow to build required indices.
"""


rule build_indices:
    input:
        get_build_indices_output,
