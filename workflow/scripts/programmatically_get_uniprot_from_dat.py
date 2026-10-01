import argparse
import csv
import gzip
import logging

from Bio import SwissProt
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord

FIELDNAMES = [
    "Entry",
    "organism_name",
    "taxonomy_id",
    "entry_name",
    "full_protein_name",
    "data_class",
    "protein_existence",
    "sequence",
    "sequence_length",
    "sequence_version",
    "organelle",
    "mass",
    "xref_ensembl",
    "go_c",
    "go_f",
    "go_p",
    "kegg",
    "developmental_stage",
    "tissue_specificity",
    "ptm",
    "disease",
    "transmem_features",
    "intramem_features",
    "topo_dom_features",
    "mod_features",
    "binding_features",
    "dna_bind_features",
    "act_site_features",
    "mutagen_features",
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


def _get_sequence_version(record):
    """Extract the sequence version from a SwissProt record.

    Args:
        record (Bio.SwissProt.Record): A SwissProt record object.

    Returns:
        str: The sequence version, or None if not found.
    """
    return record.sequence_update[1] if len(record.sequence_update) == 2 else None


def _get_taxonomy_id(record):
    """Extract the taxonomy ID from a SwissProt record.

    Args:
        record (Bio.SwissProt.Record): A SwissProt record object.

    Returns:
        str: The taxonomy ID, or None if not found.
    """
    return record.taxonomy_id[0] if record.taxonomy_id else None


def _get_comment_value(record, prefix):
    """Extract the value of a comment with a specific prefix from a SwissProt record.

    Args:
        record (Bio.SwissProt.Record): A SwissProt record object.
        prefix (str): The prefix to look for in the comment lines.

    Returns:
        list: A list of comment values with the specified prefix, or an empty list if not found.
    """
    lst = []
    for comment in record.comments:
        if comment.startswith(prefix):
            lst.append(comment.removeprefix(prefix).strip())
    return lst


def _record_to_row(record):
    """Build the shared (non-Entry/accession) fields for a SwissProt record.

    Args:
        record (Bio.SwissProt.Record): A SwissProt record object.

    Returns:
        dict: A dictionary containing the extracted fields.
    """
    length, mass, _ = record.seqinfo

    full_protein_name = _get_full_protein_name(record.description)

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

    devel_stage = _get_comment_value(record, "DEVELOPMENTAL STAGE:")
    tissue_specificity = _get_comment_value(record, "TISSUE SPECIFICITY:")
    ptm = _get_comment_value(record, "PTM:")
    disease = _get_comment_value(record, "DISEASE:")
    taxonomy_id = _get_taxonomy_id(record)
    sequence_version = _get_sequence_version(record)

    transmem, intramem, topo_dom, mod_res = [], [], [], []
    binding, dna_bind, act_site, mutagen = [], [], [], []

    for feat in record.features:
        if feat.type == "TRANSMEM":
            transmem.append(str(feat.location))
        elif feat.type == "INTRAMEM":
            intramem.append(str(feat.location))
        elif feat.type == "TOPO_DOM":
            topo_dom.append(f"{feat.qualifiers.get('note')}:{feat.location}")
        elif feat.type == "MOD_RES":
            mod_res.append(f"{feat.qualifiers.get('note')}:{feat.location}")
        elif feat.type == "BINDING":
            ligand = feat.qualifiers.get("ligand")
            binding.append(f"{ligand}:{feat.location}")
        elif feat.type == "DNA_BIND":
            dna_bind.append(str(feat.location))
        elif feat.type == "ACT_SITE":
            act_site.append(f"{feat.qualifiers.get('note')}:{feat.location}")
        elif feat.type == "MUTAGEN":
            mutagen.append(f"{feat.qualifiers.get('note')}:{feat.location}")

    return {
        "organism_name": record.organism,
        "taxonomy_id": taxonomy_id,
        "entry_name": record.entry_name,
        "full_protein_name": full_protein_name,
        "data_class": record.data_class,
        "protein_existence": record.protein_existence,
        "sequence": record.sequence,
        "sequence_length": length,
        "sequence_version": sequence_version,
        "organelle": record.organelle,
        "mass": mass,
        "xref_ensembl": LIST_SEP.join(transcripts),
        "go_c": LIST_SEP.join(go_c),
        "go_f": LIST_SEP.join(go_f),
        "go_p": LIST_SEP.join(go_p),
        "kegg": LIST_SEP.join(kegg_ids),
        "developmental_stage": LIST_SEP.join(devel_stage),
        "tissue_specificity": LIST_SEP.join(tissue_specificity),
        "ptm": LIST_SEP.join(ptm),
        "disease": LIST_SEP.join(disease),
        "transmem_features": LIST_SEP.join(transmem),
        "intramem_features": LIST_SEP.join(intramem),
        "topo_dom_features": LIST_SEP.join(topo_dom),
        "mod_features": LIST_SEP.join(mod_res),
        "binding_features": LIST_SEP.join(binding),
        "dna_bind_features": LIST_SEP.join(dna_bind),
        "act_site_features": LIST_SEP.join(act_site),
        "mutagen_features": LIST_SEP.join(mutagen),
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

    taxonomy_id = _get_taxonomy_id(record)
    gene_name = record.gene_name[0].get("Name") if record.gene_name else None
    gene_name = gene_name.partition(" {")[0].strip() if gene_name else None
    sequence_version = _get_sequence_version(record)

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


def stream_uniprot(organism_name, database_path, output_file, outfasta_sp, outfasta_tr):
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

            sequence_record = SeqRecord(
                seq=Seq(record.sequence),
                id=fastq_id,
                description=fasta_description,
            )

            if record.data_class == "Reviewed":
                SeqIO.write(
                    sequences=sequence_record,
                    handle=fasta_out_handle_sp,
                    format="fasta",
                )
            else:
                SeqIO.write(
                    sequences=sequence_record,
                    handle=fasta_out_handle_tr,
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
        "--outfile",
        type=str,
        help="Output file path for the UniProt data TSV",
        required=True,
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
        required=True,
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
        args.outfasta_sp,
        args.outfasta_tr,
    )


if __name__ == "__main__":
    main()
