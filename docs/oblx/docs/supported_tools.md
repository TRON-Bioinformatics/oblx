# Supported bioinformatics pipelines

- [nf-core/sarek](https://github.com/nf-core/sarek)
- [tronflows](https://github.com/TRON-Bioinformatics/tronflow)

# Supported bioinformatics tools

The table below lists the bioinformatics tools that consume files from the
generated genome library and which paths each tool requires.

> **Tool versions**: The pipeline does not pin downstream tool versions, but the
> indices are produced with specific tool versions. To guarantee compatibility,
> use the same tool versions for downstream analysis. The exact versions used to
> build each index are defined in the per-rule conda environments under
> [`workflow/envs/`](https://github.com/TRON-Private/tronmake-genome-lib-builder/tree/dev/workflow/envs)
> and the corresponding apptainer/docker images in
> [`config/container_config.yaml`](https://github.com/TRON-Private/tronmake-genome-lib-builder/blob/dev/config/container_config.yaml).

{{ read_table("resources/supported_tools.tsv") }}
