#!/usr/bin/env python3

import os
import pathlib
import sys
import gzip
import magic
import argparse
from contextlib import contextmanager

@contextmanager
def open_gtf_file(filename):
    """Open GTF file

    Context manager to open GTF files. Supports plain-text
    and gzipped GTF files. Compression of file is determined
    by reading the magic byte of the file.

    Args:
        filename (pathlib.Path): Path to GTF file

    Yields:
        File descriptor of GTF file
    """
    compressed = False
    magic_byte_gtf = magic.from_file(filename)
    if 'gzip compressed data' in magic_byte_gtf:
        compressed = True

    if compressed:
        with gzip.open(filename, 'rb') as f:
            yield f
    else:
        with open(filename, 'r') as f:
            yield f


CHR_LIST = (
    "chr1", "chr2", "chr3", "chr4", "chr5",
    "chr6", "chr7", "chr8", "chr9", "chr10",
    "chr11", "chr12", "chr13", "chr14", "chr15",
    "chr16", "chr17", "chr18", "chr19", "chr20",
    "chr21", "chr22", "chrX", "chrY", "chrM"
)


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


def get_tsl(gtf_info: dict) -> dict:
    pass


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


def get_gencode_basic(gtf_info: dict) -> dict:
    """Gencode basic transcripts

    Select transcripts from Gencode annotation tagged as basic

    Args:
        gtf_info (dict): Parsed GTF content

    Returns:
        dict:
    """
    basic_transcripts = ()
    for key, val in gtf_info.items():
        tags = val['tags']
        if "basic" in tags:
            basic_transcripts.add(key)
    return basic_transcripts

def get_ensembl_artifacts(gtf_info: dict) -> dict:
    """Gencode artifcats

    Select transcripts and gene models known to be artifacts from the assembly.

    Args:
        gtf_info (dict): Parsed GTF content

    Returns:
        set: A collection of transcript/gene pairs to be mask or exclude
    """
    artifacts = {}
    artifacts_bed = {}
    for key, val in gtf_info.items():
        if val['gene_type'] == "artifact":
            gene_id = val['gene_id']
            if not gene_id in artifacts:
                artifacts[gene_id] = [(val['coordinates'][1], val['coordinates'][2])]
            else:
                artifacts[gene_id].append((val['coordinates'][1], val['coordinates'][2]))
    for this_artifact, this_coordinates in artifacts.items():
        artifacts_bed[this_artifact] = [min(this_coordinates)[0], max(this_coordinates)[1]]
   
    return artifacts_bed