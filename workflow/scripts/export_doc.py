def doc_string_exporter(rule_collection, doctrings_markdown):
    """
    Function to export docstrings and software version
    """
    with open(doctrings_markdown, 'w') as file_handle:
        for rule_name, rule_docstring in rule_collection.items():
            if rule_name in ['all', 'doc_all', 'docstring_export', 'software_export']:
                continue
            file_handle.write(f'### Rule `{rule_name}`\n')
            file_handle.write(f'```\n{rule_docstring}\n```\n')

doc_string_exporter(
    rule_collection=snakemake.params.get("rule_collection"),
    doctrings_markdown=snakemake.output.doctrings_markdown
)