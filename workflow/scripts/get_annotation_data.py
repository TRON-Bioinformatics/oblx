import pathlib
from contextlib import contextmanager
import argparse

CHR_LIST = (
    "chr1", "chr2", "chr3", "chr4", "chr5",
    "chr6", "chr7", "chr8", "chr9", "chr10",
    "chr11", "chr12", "chr13", "chr14", "chr15",
    "chr16", "chr17", "chr18", "chr19", "chr20",
    "chr21", "chr22", "chrX", "chrY", "chrM"
)


@contextmanager
def open_gtf_file(filename):
    """Open GTF file

    Context manager to open GTF files.

    Args:
        filename (pathlib.Path): Path to GTF file

    Yields:
        File descriptor of GTF file
    """
    with open(filename, 'r') as f:
        yield f


def load_gtf(gtf_file: pathlib.Path):

    trans_to_gene = {}

    with open_gtf_file(gtf_file) as inf:
        for line in inf:
            if isinstance(line, bytes):
                line = line.decode()
            elements = line.rstrip().split("\t")
            # Skip comment lines
            if len(elements) < 3:
                continue
            # Select transcript features located on reference chromosomes
            # Extract required information from attributes located in field 9
            if elements[2] == "transcript" and elements[0] in CHR_LIST:
                transcript_id = ""
                gene_symbol = ""
                gene_id = ""
                gene_type = ""
                tsl = ""
                tags = []
                gtf_attributes = elements[8].rstrip(";").split(";")
                coordinates = (elements[0], int(elements[3]), int(elements[4]), elements[6])
                for i in range(len(gtf_attributes)):
                    key, val = gtf_attributes[i].strip().rsplit(" ", 1)
                    val = val.strip("\"")
                    if key == "transcript_id":
                        transcript_id = val
                    elif key == "gene_name":
                        gene_symbol = val
                    elif key == "gene_id":
                        gene_id = val
                    elif key == "gene_type":
                        gene_type = val
                    elif key == "transcript_support_level":
                        tsl = val
                    elif key == "tag":
                        tags.append(val)
                    else:
                        continue

                trans_to_gene[transcript_id] = {'gene_id': gene_id,
                                                'gene_symbol': gene_symbol,
                                                'gene_type': gene_type,
                                                'tsl': tsl,
                                                'tags': tags, "coordinates" : coordinates}
    return trans_to_gene


def get_gene2hgnc(gtf_info: dict) -> set:
    """

    Args:
        gtf_info:

    Returns:

    """
    gene_to_hgnc = set()
    for _, val in gtf_info.items():
        gene_to_hgnc.add((val['gene_id'], val['gene_symbol']))
    return gene_to_hgnc


# Main

parser = argparse.ArgumentParser(
    description="Extract gene to HGNC mapping from GTF file"
)
parser.add_argument(
    "--outfile",
    type=str,
    help="Output TSV file",
    required=True,
)
parser.add_argument(
    "--gtf",
    type=str,
    help="Path to GTF file",
    required=True,
)


args = parser.parse_args()

gtf_info = load_gtf(args.gtf)

gene2hgnc = get_gene2hgnc(gtf_info)
with open(args.outfile, "w") as file_hande:
    file_hande.write('gene_id\tgene_symbol\n')
    for pair in gene2hgnc:
        file_hande.write('{}\t{}\n'.format(pair[0], pair[1]))
