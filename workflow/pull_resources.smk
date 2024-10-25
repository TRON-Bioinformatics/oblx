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
UCSC_URL = "https://hgdownload.soe.ucsc.edu/gbdb/hg38"
UCSC_GOLDEN_PATH_URL = "https://hgdownload.soe.ucsc.edu/goldenPath"
GATK_URL = "https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0"

default_build = 'GRCh38'
default_release = '46'

include: "rules/common.smk"

rule all:
    input:
        get_pull_resources_output
    

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

rule download_ucsc_data:
    input:
        # https://hgdownload.soe.ucsc.edu/gbdb/hg38/problematic/encBlacklist.bb
        encode_exclusion_remote = storage(
            "{}/problematic/encBlacklist.bb".format(UCSC_URL)),
        # https://hgdownload.soe.ucsc.edu/gbdb/hg38/problematic/grcExclusions.bb
        grc_exclusion_remote = storage(
            "{}/problematic/grcExclusions.bb".format(UCSC_URL)),
        # https://hgdownload.soe.ucsc.edu/gbdb/hg38/problematic/comments.bb
        ucsc_problematic_remote = storage(
            "{}/problematic/comments.bb".format(UCSC_URL)),
        # https://hgdownload.soe.ucsc.edu/gbdb/hg38/gencode/gencodeV46.bb
        gencode_bed12_remote = storage(
            "{}/gencode/gencodeV46.bb".format(UCSC_URL)),
        # https://hgdownload.soe.ucsc.edu/goldenPath/hg38/database/rmsk.txt.gz
        rmsk_remote = storage(
            "{}/hg38/database/rmsk.txt.gz".format(UCSC_GOLDEN_PATH_URL)),
    output:
        encode_exclusion = temp("resources/mappability/encode_exclusion.bb"),
        grc_exclusion = temp("resources/mappability/grcExclusions.bb"),
        ucsc_problematic = temp("resources/mappability/ucsc_problematic.bb"),
        gencode_bed = temp("resources/ref_annot.bb"),
        rmsk_annot = temp("resources/ucsc_repeatmasker_dump.txt.gz")
    shell:
        '''
        cp {input.encode_exclusion_remote} {output.encode_exclusion}
        cp {input.grc_exclusion_remote} {output.grc_exclusion}
        cp {input.ucsc_problematic_remote} {output.ucsc_problematic}
        cp {input.gencode_bed12_remote} {output.gencode_bed}
        cp {input.rmsk_remote} {output.rmsk_annot}
        '''

rule download_exome_probesets:
    """
    Download common exome capture kits for WES analysis
    Here we download kits from Twist and Agilent
    """
    input:
        # https://hgdownload.soe.ucsc.edu/gbdb/hg38/problematic/encBlacklist.bb
        twist_refseq_remote = storage(
            "exomeProbesets/Twist_Exome_RefSeq_targets_hg38.bb".format(UCSC_URL)),
        twist_core_exome_remote = storage(
            "exomeProbesets/Twist_Exome_Target_hg38.bb".format(UCSC_URL)),
        twist_comprehensive_exome_remote = storage(
            "exomeProbesets/Twist_ComprehensiveExome_targets_hg38.bb".format(UCSC_URL)),
        twist_exome2_remote = storage(
            "exomeProbesets/TwistExome21.bb".format(UCSC_URL)),
    output:
        twist_refseq = temp("resources/exome_definition/twist_refseq.bb"),
        twist_core_exome = temp("resources/exome_definition/twist_core_exome.bb"),
        twist_comprehensive_exome = temp("resources/exome_definition/twist_comprehensive_exome.bb"),
        twist_exome2 = temp("resources/exome_definition/twist_exome2.bb")
    shell:
        '''
        cp {input.twist_refseq_remote} {output.twist_refseq}
        cp {input.twist_core_exome_remote} {output.twist_core_exome}
        cp {input.twist_comprehensive_exome_remote} {output.twist_comprehensive_exome}
        cp {input.twist_exome2_remote} {output.twist_exome2}
        '''

rule bb_to_bed:
    """
    Convert UCSC binary bigbed to ASCII bed
    """
    input:
        encode_exclusion = "resources/mappability/encode_exclusion.bb",
        ucsc_problematic = "resources/mappability/ucsc_problematic.bb",
        grc_exclusion = "resources/mappability/grcExclusions.bb",
        gencode_bed = "resources/ref_annot.bb",
        twist_refseq = "resources/exome_definition/twist_refseq.bb",
        twist_core_exome = "resources/exome_definition/twist_core_exome.bb",
        twist_comprehensive_exome = "resources/exome_definition/twist_comprehensive_exome.bb",
        twist_exome2 = "resources/exome_definition/twist_exome2.bb"
    output:
        encode_exclusion = "resources/mappability/encode_exclusion.bed",
        grc_exclusion = "resources/mappability/grcExclusions.bed",
        ucsc_problematic = "resources/mappability/ucsc_problematic.bed",
        gencode_bed = "resources/ref_annot.bed",
        twist_refseq = "resources/exome_definition/twist_refseq.bed",
        twist_core_exome = "resources/exome_definition/twist_core_exome.bed",
        twist_comprehensive_exome = "resources/exome_definition/twist_comprehensive_exome.bed",
        twist_exome2 = "resources/exome_definition/twist_exome2.bed"
    shell:
        '''
        bigBedToBed {input.encode_exclusion} {output.encode_exclusion}
        bigBedToBed {input.grc_exclusion} {output.grc_exclusion}
        bigBedToBed {input.ucsc_problematic} {output.ucsc_problematic}
        bigBedToBed {input.gencode_bed} {output.gencode_bed}
        bigBedToBed {input.twist_refseq} {output.twist_refseq}
        bigBedToBed {input.twist_core_exome} {output.twist_core_exome}
        bigBedToBed {input.twist_comprehensive_exome} {output.twist_comprehensive_exome}
        bigBedToBed {input.twist_exome2} {output.twist_exome2}
        '''

rule download_gatk_bundle:
    input:
        # Mills and 1000G gold standard
        mills_remote = storage(
            "{}/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz".format(GATK_URL)),
        # HG38 known indels Homo_sapiens_assembly38.known_indels.vcf.gz
        known_indels_remote = storage(
            "{}/Homo_sapiens_assembly38.known_indels.vcf.gz".format(GATK_URL)),
        dbsnp_remote = storage(
            "{}/Homo_sapiens_assembly38.dbsnp138.vcf".format(GATK_URL)),
            
    output:
        
    shell:
        "..."
