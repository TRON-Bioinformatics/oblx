import argparse
import os
import pandas as pd


def main():
    parser = argparse.ArgumentParser(
        description="Merge Gencode to UniProt mapping with UniProt annotations"
    )

    parser.add_argument(
        "--outfile",
        type=str,
        default="uniprot_annotation_gencode_mapped.tsv",
        help="Output TSV file",
    )
    parser.add_argument(
        "--sp-mapping",
        type=str,
        help="Path to Gencode transcript_id to SwissProt accession mapping TSV file (https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_<organism>/release_<release>/gencode.v<release>.metadata.SwissProt.gz)",
        required=True,
    )
    parser.add_argument(
        "--tr-mapping",
        type=str,
        help="Path to Gencode transcript_id to TrEMBL accession mapping TSV file (https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_<organism>/release_<release>/gencode.v<release>.metadata.TrEMBL.gz)",
        required=True,
    )
    parser.add_argument(
        "--uniprot",
        type=str,
        help="Path to fetched UniProt annotation TSV file",
        required=True,
    )

    args = parser.parse_args()

    sp_mapping = pd.read_csv(
        args.sp_mapping, sep="\t", names=["transcript_id", "Entry", "Entry_version"]
    )
    sp_mapping = sp_mapping[["transcript_id", "Entry"]]
    sp_mapping["Source"] = "SwissProt"

    print(sp_mapping)

    tr_mapping = pd.read_csv(
        args.tr_mapping, sep="\t", names=["transcript_id", "Entry", "Entry_version"]
    )
    tr_mapping = tr_mapping[["transcript_id", "Entry"]]
    tr_mapping["Source"] = "TrEMBL"

    print(tr_mapping)

    mapping = pd.concat([sp_mapping, tr_mapping], axis=0)

    print(mapping)

    uniprot = pd.read_csv(args.uniprot, sep="\t", low_memory=False)

    print(uniprot)

    merged = pd.merge(mapping, uniprot, how="left", on="Entry")

    merged.to_csv(args.outfile, sep="\t", index=False)


if __name__ == "__main__":
    main()
