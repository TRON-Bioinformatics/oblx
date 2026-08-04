import argparse
import csv
import os
import gzip
import logging

from Bio import SwissProt

FIELDNAMES = [
    "Entry",
    "organism_name",
    "entry_name",
    "protein_existence",
    "sequence",
    "sequence_length",
    "organelle",
    "mass",
    "xref_ensembl",
    "go_c",
    "go_f",
    "go_p",
    "kegg",
    "transmem_features",
    "intramem_features",
    "topo_dom_features",
    "mod_features",
]

LIST_SEP = ";"


def _record_to_row(record):
    """Build the shared (non-Entry/accession) fields for a SwissProt record.

    Args:
        record (Bio.SwissProt.Record): A SwissProt record object.

    Returns:
        dict: A dictionary containing the extracted fields.
    """
    length, mass, _ = record.seqinfo

    transcripts, go_c, go_f, go_p, kegg_ids = [], [], [], [], []
    for xref in record.cross_references:
        if xref[0] == "Ensembl":
            transcripts.append(xref[1])
        elif xref[0] == "GO":
            if xref[2].startswith("C:"):
                go_c.append(xref[1])
            elif xref[2].startswith("F:"):
                go_f.append(xref[1])
            elif xref[2].startswith("P:"):
                go_p.append(xref[1])
        elif xref[0] == "KEGG":
            kegg_ids.append(xref[1])

    transmem, intramem, topo_dom, mod_res = [], [], [], []
    for feat in record.features:
        if feat.type == "TRANSMEM":
            transmem.append(str(feat.location))
        elif feat.type == "INTRAMEM":
            intramem.append(str(feat.location))
        elif feat.type == "TOPO_DOM":
            topo_dom.append(f"{feat.qualifiers.get('note')}:{feat.location}")
        elif feat.type == "MOD_RES":
            mod_res.append(f"{feat.qualifiers.get('note')}:{feat.location}")

    return {
        "organism_name": record.organism,
        "entry_name": record.entry_name,
        "protein_existence": record.protein_existence,
        "sequence": record.sequence,
        "sequence_length": length,
        "organelle": record.organelle,
        "mass": mass,
        "xref_ensembl": LIST_SEP.join(transcripts),
        "go_c": LIST_SEP.join(go_c),
        "go_f": LIST_SEP.join(go_f),
        "go_p": LIST_SEP.join(go_p),
        "kegg": LIST_SEP.join(kegg_ids),
        "transmem_features": LIST_SEP.join(transmem),
        "intramem_features": LIST_SEP.join(intramem),
        "topo_dom_features": LIST_SEP.join(topo_dom),
        "mod_features": LIST_SEP.join(mod_res),
    }


def stream_uniprot(organism_name, database_path, output_file):
    """Stream UniProt records for a specific organism and write to a TSV file.

    Args:
        organism_name (str): The name of the organism to filter records.
        database_path (str): Path to the UniProt database file (gzipped).
        output_file (str): Path to the output TSV file.
    """
    logging.info("Parsing UniProt database: %s", database_path)
    n_records = 0
    with gzip.open(database_path, "rb") as handle, open(
        output_file, "w", newline="", encoding="utf-8"
    ) as out:
        writer = csv.DictWriter(
            out,
            fieldnames=FIELDNAMES,
            delimiter="\t",
            lineterminator="\n",
        )
        writer.writeheader()

        for record in SwissProt.parse(handle):
            if record.organism != organism_name:
                continue
            base = _record_to_row(record)
            # one row per accession (mirrors df.explode("Entry"))
            for acc in record.accessions:
                writer.writerow({"Entry": acc, **base})
            n_records += 1

    logging.info("Wrote %d records for %s to %s", n_records, organism_name, output_file)


def main():
    parser = argparse.ArgumentParser(
        description="Fetch UniProt data for human and mouse"
    )

    parser.add_argument(
        "--outfile", type=str, help="Output file path for the UniProt data TSV"
    )
    parser.add_argument(
        "--database",
        type=str,
        help="Path to the UniProt database file (gzipped .dat.gz)",
    )
    parser.add_argument(
        "--organism",
        type=str,
        default="human",
        help="Name of the organism (human or mouse)",
    )

    args = parser.parse_args()

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
    )

    # Get human and mouse data
    if args.organism == "human":
        organism_name = "Homo sapiens (Human)."
    elif args.organism == "mouse":
        organism_name = "Mus musculus (Mouse)."
    else:
        raise ValueError(
            f"Organism '{args.organism}' is not valid. Please use 'human' or 'mouse'."
        )

    stream_uniprot(organism_name, args.database, args.outfile)


if __name__ == "__main__":
    main()
