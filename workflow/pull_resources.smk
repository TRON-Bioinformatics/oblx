"""
Snakemake workflow to pull all reqiured reference files for GENCODE.

Make sure to specify a yaml config via --configfile containing the following keys:
* organism: 'human' or 'mouse'
* release: The gencode release (e.g. 45 for human or M35 for mouse)
* genome-build: The genome build name (e.g. GRCh38 for human or GRCm39 for mouse)

@author: Luis Kress (TRON), Johannes Hausmann (TRON)
@version: 20240522
"""
import os
from snakemake.utils import min_version

min_version('8.5.4')

GENCODE_URL = "https://ftp.ebi.ac.uk/pub/databases/gencode"
UCSC_URL = "https://hgdownload.soe.ucsc.edu/gbdb/hg38/"

default_build = 'GRCh38'
default_release = '46'

rule all:
    input:
        'resources/ref_genome.fasta',
        'resources/ref_genome.fasta.fai',
        'resources/ref_annot.gtf',
        'resources/ref_transcripts.fasta'

rule download_gencode_data:
    """Rule to download annotation data

    Downloads the required reference genome (fasta) and 
    transcript annotation (gtf) from GENCODE ftp server

    input:
        fasta_remote (storage): RemoteProvider pointing to fasta on GENCODE ftp
        gtf_remote (storage): RemoteProvider pointing to fasta on GENCODE ftp
    output:
        fasta (string): Path to gzipped fasta file
        gtf (string): Path to gzipped gtf file

    """
    input:
        fasta_remote = storage(
            "{}/Gencode_{}/release_{}/{}.primary_assembly.genome.fa.gz".format(
                GENCODE_URL,
                config.get('organism', 'human'),
                config.get('release', default_release),
                config.get('genome-build', default_build)
            )
        ),
        gtf_remote = storage(
            "{}/Gencode_{}/release_{}/gencode.v{}.basic.annotation.gtf.gz".format(
                GENCODE_URL,
                config.get('organism', 'human'),
                config.get('release', default_release),
                config.get('release', default_release)
            )
        ),
        transcripts_remote = storage(
            "{}/Gencode_{}/release_{}/gencode.v{}.transcripts.fa.gz".format(
                GENCODE_URL,
                config.get('organism', 'human'),
                config.get('release', default_release),
                config.get('release', default_release)
            )
        ),
        swissprot_remote = storage(
            "{}/Gencode_{}/release_{}/gencode.v{}.metadata.SwissProt.gz".format(
                GENCODE_URL,
                config.get('organism', 'human'),
                config.get('release', default_release),
                config.get('release', default_release)
            )
        ),
        trembl_remote = storage(
            "{}/Gencode_{}/release_{}/gencode.v{}.metadata.TrEMBL.gz".format(
                GENCODE_URL,
                config.get('organism', 'human'),
                config.get('release', default_release),
                config.get('release', default_release)
            )
        ),

    output:
        fasta = temp(
            "resources/GENCODE_GRC{}{}v{}_dna.fasta.gz".format(
                'h' if config['organism'] == 'human' else 'm',
                config.get('genome-build', default_build),
                config.get('release', default_release)
        )),
        gtf = temp(
            "resources/GENCODE_GRC{}{}v{}_annot.gtf.gz".format(
                'h' if config['organism'] == 'human' else 'm',
                config.get('genome-build', default_build),
                config.get('release', default_release)
        )),
        transcripts = temp(
            "resources/GENCODE_GRC{}{}v{}_transcripts.fasta.gz".format(
                'h' if config['organism'] == 'human' else 'm',
                config.get('genome-build', default_build),
                config.get('release', default_release)
        )),
        swissprot = temp(
            "resources/GENCODE_GRC{}{}v{}_metadata.SwissProt.gz".format(
                'h' if config['organism'] == 'human' else 'm',
                config.get('genome-build', default_build),
                config.get('release', default_release)
        )),
        trembl = temp(
            "resources/GENCODE_GRC{}{}v{}_metadata.TrEMBL.gz".format(
                'h' if config['organism'] == 'human' else 'm',
                config.get('genome-build', default_build),
                config.get('release', default_release)
        )),
    shell:
        '''
        cp {input.transcripts_remote} {output.transcripts}
        cp {input.gtf_remote} {output.gtf}
        cp {input.fasta_remote} {output.fasta}
        cp {input.swissprot_remote} {output.swissprot}
        cp {input.trembl_remote} {output.trembl}
        '''


rule gunzip_annotation_data:
    """gunzip annotation data

    Extracts the annotation archives with gunzip.
    Original archives are kept so snakemake doesn't
    trigger a rerun each time.

    This rule requires gzip >= 1.6 for the usage of
    --keep flag.

    input:
        fasta_gzipped (string): Path to fasta gzip archive
        gtf_gzipped (string): Path to gtf gzip archive
    output:
        fasta (string): Path to gunzipped fasta file
        gtf (string): Path to gunzipped gtf file

    """
    input:
        fasta_gzipped = rules.download_gencode_data.output.fasta,
        gtf_gzipped = rules.download_gencode_data.output.gtf,
        transcripts_gzipped = rules.download_gencode_data.output.transcripts,
        swissprot_gzipped = rules.download_gencode_data.output.swissprot,
        trembl_gzipped = rules.download_gencode_data.output.trembl
    output:
        fasta = 'resources/ref_genome.fasta',
        gtf = 'resources/ref_annot.gtf',
        transcripts = 'resources/ref_transcripts.fasta',
        swissprot = 'resources/ref_annot_metadata_SwissProt.tsv',
        trembl = 'resources/ref_annot_metadata_TrEMBL.tsv'
    shell:
        '''
        gunzip -c {input.fasta_gzipped} > {output.fasta}
        gunzip -c {input.gtf_gzipped} > {output.gtf}
        gunzip -c {input.transcripts_gzipped} > {output.transcripts}
        gunzip -c {input.swissprot_gzipped} > {output.swissprot}
        gunzip -c {input.trembl_gzipped} > {output.trembl}
        '''


rule samtools_faidx:
    """
    Generate FASTA index of reference genome
    """
    input:
        fasta = rules.gunzip_annotation_data.output.fasta
    output:
       fai = "resources/ref_genome.fasta.fai"
    conda:
        'envs/samtools.yaml'
    shell:
        '''
	    samtools faidx {input.fasta}
        '''

rule download_ucsc_data:
    input:
        # https://hgdownload.soe.ucsc.edu/gbdb/hg38/problematic/encBlacklist.bb
        encode_exclusion_remote = storage(
            "{}/problematic/encBlacklist.bb".format(UCSC_URL)),
        # https://hgdownload.soe.ucsc.edu/gbdb/hg38/problematic/grcExclusions.bb
        grc_exclusion_remote = storage(
            "{}/problematic/grcExclusions.bb".format(UCSC_URL)),
        

    output:
    shell:

