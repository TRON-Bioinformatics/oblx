import pathlib
import re
import argparse
import gzip
import sys

RELEASE_PATTERN = re.compile(r"UniProtKB/Swiss-Prot\s+Release\s+(\d{4}_\d{2})")


def parse_uniprot_release(external_data_file: pathlib.Path) -> str | None:
    """
    Parse the uniprot release from the ENSEMBL external_data.txt.gz file.

    Args:
        external_data_file: Path to the external_data.txt.gz file.
    """
    with gzip.open(external_data_file, "rt", encoding="utf-8") as file:
        for line in file:
            match = RELEASE_PATTERN.search(line)
            if match:
                release = match.group(1)
                return release

    print("Uniprot release not found in external_data.txt.gz file.")
    return None


# Main

parser = argparse.ArgumentParser(
    description="Extract uniprot release from ENSEMBL external_data.txt.gz file"
)
parser.add_argument(
    "--outfile",
    type=str,
    help="Output TSV file",
    required=True,
)
parser.add_argument(
    "--external_data",
    type=str,
    help="Path external_data.txt.gz file",
    required=True,
)


args = parser.parse_args()

release = parse_uniprot_release(pathlib.Path(args.external_data))

if release is None:
    sys.exit(1)

with open(args.outfile, "w", encoding="utf-8") as file_handle:
    file_handle.write(f"Release\t{release}\n")
