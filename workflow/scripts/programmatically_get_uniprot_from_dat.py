import argparse
import csv
import os
import gzip
import logging

from Bio import SwissProt
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord

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


def _get_full_protein_name(description):
    """Parse the description line of a UniProt record to extract the protein name.

    Args:
        description (str): The description line from a UniProt record.

    Returns:
        str: The extracted protein name.
    """
    # example description string:
    # 'RecName: Full=14-3-3 protein epsilon; Short=14-3-3E;'
    protein_name = ""
    for part in description.split(";"):
        part = part.strip()
        if part.startswith(("RecName: Full=", "SubName: Full=")):
            protein_name = part.partition("Full=")[2]
            # Remove evidence annotation, e.g. {ECO:0000305}
            return protein_name.partition(" {")[0].strip()

    logging.warning("No full protein name found in description: %s", description)
    return protein_name


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


def _get_fasta_id_and_description(record):
    """Construct the FASTA header for a UniProt record.

    The format of the FASTA header follows the UniProt convention:
        ><sp_or_tr>|<primary_accession>|<entry_name> <full_protein_name> OS=<organism_name> OX=<taxonomy_id> GN=<gene_name> PE=<protein_existence> SV=<sequence_version>
    If any of OS, OX, GN, PE, or SV are missing, they will be omitted from the header.

    Args:
        record (Bio.SwissProt.Record): A SwissProt record object.

    Returns:
        tuple: A tuple containing the FASTA ID string and the description string.
    """
    data_class = "sp" if record.data_class == "Reviewed" else "tr"
    accession = record.accessions[0] if record.accessions else record.entry_name

    fasta_id = f"{data_class}|{accession}|{record.entry_name}"

    protein_name = _get_full_protein_name(record.description)

    organism = record.organism.partition(" (")[0] if record.organism else None

    taxonomy_id = record.taxonomy_id[0] if record.taxonomy_id else None
    gene_name = record.gene_name[0].get("Name") if record.gene_name else None
    gene_name = gene_name.partition(" {")[0].strip() if gene_name else None
    sequence_version = (
        record.sequence_update[1] if len(record.sequence_update) == 2 else None
    )

    fields = [
        protein_name,
        f"OS={organism}" if organism else None,
        f"OX={taxonomy_id}" if taxonomy_id else None,
        f"GN={gene_name}" if gene_name else None,
        f"PE={record.protein_existence}" if record.protein_existence else None,
        f"SV={sequence_version}" if sequence_version else None,
    ]

    description = " ".join(field for field in fields if field)

    return fasta_id, description


def stream_uniprot(
    organism_name, database_path, output_file, outfasta, outfasta_sp, outfasta_tr
):
    """Stream UniProt records for a specific organism and write to a TSV file.

    Args:
        organism_name (str): The name of the organism to filter records.
        database_path (str): Path to the UniProt database file (gzipped).
        output_file (str): Path to the output TSV file.
    """
    logging.info("Parsing UniProt database: %s", database_path)
    n_records = 0
    with (
        # UniProt database reader from gzipped .dat file
        gzip.open(database_path, "rb") as handle,
        # TSV writer for UniProt data
        open(output_file, "w", newline="", encoding="utf-8") as out,
        # FASTA writer for all UniProt sequences
        open(outfasta, "w", newline="", encoding="utf-8") as fasta_out_handle,
        # FASTA writer for reviewed UniProt sequences
        open(outfasta_sp, "w", newline="", encoding="utf-8") as fasta_out_handle_sp,
        # FASTA writer for unreviewed UniProt sequences
        open(outfasta_tr, "w", newline="", encoding="utf-8") as fasta_out_handle_tr,
    ):
        writer = csv.DictWriter(
            out,
            fieldnames=FIELDNAMES,
            delimiter="\t",
            lineterminator="\n",
        )
        writer.writeheader()

        for record in SwissProt.parse(handle):
            # Skip records that do not match the specified organism.
            # E.g. "Homo sapiens" will match "Homo sapiens (Human)."
            #      "Rattus norvegicus" will match "Rattus norvegicus (Rat)."
            if not record.organism.startswith(organism_name):
                continue
            base = _record_to_row(record)
            # one row per accession (mirrors df.explode("Entry"))
            for acc in record.accessions:
                writer.writerow({"Entry": acc, **base})

            # Write the sequence to the FASTA file
            fastq_id, fasta_description = _get_fasta_id_and_description(record)

            if record.data_class == "Reviewed":
                SeqIO.write(
                    sequences=SeqRecord(
                        seq=Seq(record.sequence),
                        id=fastq_id,
                        description=fasta_description,
                    ),
                    handle=fasta_out_handle_sp,
                    format="fasta",
                )
            else:
                SeqIO.write(
                    sequences=SeqRecord(
                        seq=Seq(record.sequence),
                        id=fastq_id,
                        description=fasta_description,
                    ),
                    handle=fasta_out_handle_tr,
                    format="fasta",
                )
            # Write the sequence to the general FASTA file (with all sequences)
            SeqIO.write(
                sequences=SeqRecord(
                    seq=Seq(record.sequence),
                    id=fastq_id,
                    description=fasta_description,
                ),
                handle=fasta_out_handle,
                format="fasta",
            )

            n_records += 1

    logging.info(
        "Wrote %d unique records for %s to %s", n_records, organism_name, output_file
    )


def main():
    parser = argparse.ArgumentParser(
        description="Fetch UniProt data for human and mouse"
    )

    parser.add_argument(
        "--outfile", type=str, help="Output file path for the UniProt data TSV"
    )
    parser.add_argument(
        "--outfasta", type=str, help="Output file path for the UniProt data FASTA"
    )
    parser.add_argument(
        "--outfasta-sp",
        type=str,
        help="Output file path for the UniProt data FASTA for reviewed entries",
        required=True,
    )
    parser.add_argument(
        "--outfasta-tr",
        type=str,
        help="Output file path for the UniProt data FASTA for unreviewed entries",
        required=True,
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
        organism_name = "Homo sapiens"
    elif args.organism == "mouse":
        organism_name = "Mus musculus"
    else:
        organism_name = args.organism.replace("_", " ")

    stream_uniprot(
        organism_name,
        args.database,
        args.outfile,
        args.outfasta,
        args.outfasta_sp,
        args.outfasta_tr,
    )


if __name__ == "__main__":
    main()
