import extract_gtf_annotation

gtf = snakemake.input['gtf']
gtf_info = extract_gtf_annotation.load_gtf(gtf)

gene2hgnc = extract_gtf_annotation.get_gene2hgnc(gtf_info)
with open(snakemake.output['mapping_table'], "w") as file_hande:
    file_hande.write('gene_id\tgene_symbol\n')
    for pair in gene2hgnc:
        file_hande.write(f'{pair[0]}\t{pair[1]}\n')


