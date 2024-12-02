def software_exporter(software_collection, software_table):
    """
    Function to export docstrings and software version
    """
    with open(software_table, "w") as sof_handle:
        sof_handle.write('Rule\tConda environment\tDocker container\n')
        for rule_name, rule_software in software_collection.items():
            if not rule_name in ['all', 'docstring_export']:
                # Document conda environment and docker image URLs
                if not rule_software["conda"] is None:
                    conda_env = rule_software["conda"].replace('..', 'workflow')
                else:
                    conda_env = None
                if not rule_software["container"] is None:
                    container_img = rule_software["container"].removeprefix("docker://")
                else:
                    container_img = None
                sof_handle.write(f'{rule_name}\t{conda_env}\t{container_img}\n')
                

software_exporter(
    software_collection=snakemake.params.get("software_collection"),
    software_table=snakemake.output.software_table
)