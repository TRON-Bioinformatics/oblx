import requests
import argparse
import os

# Define the output fields (https://www.uniprot.org/help/return_fields)
fields = [
    # Databases / External links
    "xref_ensembl",
    "xref_kegg",
    # Names and Taxonomy
    "organism_name",
    "organism_id",
    "accession",
    "id",
    "protein_name",
    "gene_names",
    "gene_primary",
    # Sequences
    "cc_sc_epred",
    "sequence_version",
    "mass",
    "length",
    # Function
    "ft_binding",
    "ft_dna_bind",
    "temp_dependence",
    "cc_pathway",
    # Miscellaneous
    "annotation_score",
    "cc_caution",
    "keyword",
    "protein_existence",
    "reviewed",
    "tools",
    # Expression
    "cc_developmental_stage",
    "cc_induction",
    "cc_tissue_specificity",
    # Gene Ontology (GO)
    "go_p",
    "go_c",
    "go_f",
    "go",
    "go_id",
    # Pathology and Biotech
    "cc_disease",
    "ft_mutagen",
    # Subcellular location
    "cc_subcellular_location",
    "ft_intramem",
    "ft_transmem",
    "ft_topo_dom",
    # PTM / Processing
    "ft_mod_res",
    "ft_crosslnk",
]


def main():
    parser = argparse.ArgumentParser(
        description="Fetch UniProt data for human and mouse"
    )

    parser.add_argument(
        "--outdir", type=str, default=".", help="Output directory for the TSV file"
    )
    parser.add_argument(
        "--organism",
        type=str,
        default="human",
        help="Name of the organism (human or mouse)",
    )

    args = parser.parse_args()

    # Downside of the UniProt REST API: no possibility to specify the release

    # UniProt stream endpoint
    stream_url = "https://rest.uniprot.org/uniprotkb/stream"

    # Get human and mouse data
    if args.organism == "human":
        organism_id = "9606"
    elif args.organism == "mouse":
        organism_id = "10090"
    else:
        raise ValueError(
            f"Organism '{args.organism}' is not valid. Please use 'human' or 'mouse'."
        )

    query = f"organism_id:{organism_id}"

    params = {
        "query": query,
        "format": "tsv",
        "fields": ",".join(fields),
        "compressed": "false",  # true = gzip file, false = plain text
    }

    # Make the request in streaming mode
    response = requests.get(stream_url, params=params, stream=True)
    response.raise_for_status()

    release = response.headers.get("X-UniProt-Release")

    print("Fetching UniProt release:", release, "for", args.organism)

    # Write to TSV file
    output_file = os.path.join(args.outdir, f"uniprot_stream.tsv")

    with open(output_file, "w", encoding="utf-8") as f:
        for line in response.iter_lines(decode_unicode=True):
            if line:
                f.write(line + "\n")


if __name__ == "__main__":
    main()
