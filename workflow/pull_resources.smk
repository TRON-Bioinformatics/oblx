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
import sys
import pandas as pd
from snakemake.utils import min_version

min_version('8.5.4')

default_build = 'GRCh38'
default_release = '46'
default_organism = 'human'
gencode_or_ucsc = None
gencode2ensembl_file = 'resources/gencode2ensembl_human.tsv'
ucsc_genome_build = 'hg38'

include: "rules/common.smk"
include: "rules/intervals.smk"
include: "rules/faidx.smk"
include: "rules/prepare_ucsc.smk"
include: "rules/genome_masking.smk"
include: "rules/sequence_dict.smk"

configfile: workflow.source_path("../config/default.yaml")

# check if genome build is supported
if config.get('genome-build', default_build) not in ['GRCh38', 'GRCm38', 'GRCm39']:
    sys.exit(f'Genome build {config.get('genome-build', default_build)} not supported.')

# set mouse specific variables
if config.get('organism', default_organism) == 'mouse':
    if not config.get('release', None):
        sys.exit('When running with non human organism, "release" has to be specified in the config')    
    gencode_or_ucsc = 'gencode' if config['genome-build'] < 'GRCm39' else 'UCSC'
    ucsc_genome_build = 'mm39' if config['genome-build'] == 'GRCm39' else 'mm10'

# translate the gencode version to ensembl version for ensembl specific resources
gencode2ensembl = pd.read_csv(
        workflow.source_path(gencode2ensembl_file), 
        sep = '\t',
        dtype = str
    )
ensembl_version = gencode2ensembl[gencode2ensembl.GENCODE_release == config['release']].Ensembl_release.values[0]

onstart:
    # write the config to the output directory for reproducibility
    if not os.path.exists('configs'):
        os.mkdir('configs')
    with open(f'configs/{timestamp}_pull_resources_config.yaml', 'w') as configfile:
        yaml.dump(config, configfile, default_flow_style=False)

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
                config['GENCODE_URL'],
                config.get('organism', default_organism),
                config.get('release', default_release),
                config.get('genome-build', default_build)
            )
        ),
        gtf_remote = storage(
            "{}/Gencode_{}/release_{}/gencode.v{}.primary_assembly.annotation.gtf.gz".format(
                config['GENCODE_URL'],
                config.get('organism', default_organism),
                config.get('release', default_release),
                config.get('release', default_release)
            )
        ),
        transcripts_remote = storage(
            "{}/Gencode_{}/release_{}/gencode.v{}.transcripts.fa.gz".format(
                config['GENCODE_URL'],
                config.get('organism', default_organism),
                config.get('release', default_release),
                config.get('release', default_release)
            )
        ),
        swissprot_remote = storage(
            "{}/Gencode_{}/release_{}/gencode.v{}.metadata.SwissProt.gz".format(
                config['GENCODE_URL'],
                config.get('organism', default_organism),
                config.get('release', default_release),
                config.get('release', default_release)
            )
        ),
        trembl_remote = storage(
            "{}/Gencode_{}/release_{}/gencode.v{}.metadata.TrEMBL.gz".format(
                config['GENCODE_URL'],
                config.get('organism', default_organism),
                config.get('release', default_release),
                config.get('release', default_release)
            )
        ),

    output:
        fasta = temp(
            "resources/GENCODE_GRC{}{}v{}_dna.fasta.gz".format(
                'h' if config.get('organism', default_organism) == default_organism else 'm',
                config.get('genome-build', default_build),
                config.get('release', default_release)
        )),
        gtf = temp(
            "resources/GENCODE_GRC{}{}v{}_annot.gtf.gz".format(
                'h' if config.get('organism', default_organism) == default_organism else 'm',
                config.get('genome-build', default_build),
                config.get('release', default_release)
        )),
        transcripts = temp(
            "resources/GENCODE_GRC{}{}v{}_transcripts.fasta.gz".format(
                'h' if config.get('organism', default_organism) == default_organism else 'm',
                config.get('genome-build', default_build),
                config.get('release', default_release)
        )),
        swissprot = temp(
            "resources/GENCODE_GRC{}{}v{}_metadata.SwissProt.gz".format(
                'h' if config.get('organism', default_organism) == default_organism else 'm',
                config.get('genome-build', default_build),
                config.get('release', default_release)
        )),
        trembl = temp(
            "resources/GENCODE_GRC{}{}v{}_metadata.TrEMBL.gz".format(
                'h' if config.get('organism', default_organism) == default_organism else 'm',
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
        fasta = 'resources/ref_genome_primary.fasta',
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
    """
    Download UCSC annotation data for hg38. This
    includes problematic regions as defined by ENCODE and UCSC.
    Morerover we obtain the GRC exclusion regions that should be masked
    by default and a BED12 file of the reference transcripts.
    """
    input:
        # https://hgdownload.soe.ucsc.edu/gbdb/hg38/problematic/encBlacklist.bb
        encode_exclusion_remote = storage(
            "{}/problematic/encBlacklist.bb".format(config['UCSC_URL'])),
        # https://hgdownload.soe.ucsc.edu/gbdb/hg38/problematic/grcExclusions.bb
        grc_exclusion_remote = storage(
            "{}/problematic/grcExclusions.bb".format(config['UCSC_URL'])),
        # https://hgdownload.soe.ucsc.edu/gbdb/hg38/problematic/comments.bb
        ucsc_problematic_remote = storage(
            "{}/problematic/comments.bb".format(config['UCSC_URL'])),
        # https://hgdownload.soe.ucsc.edu/gbdb/hg38/gencode/gencodeV46.bb
        gencode_bed12_remote = storage(
            "{}/gencode/gencodeV{}.bb".format(config['UCSC_URL'], config.get('release', default_release)))
    output:
        encode_exclusion = temp("resources/mappability/encode_exclusion.bb"),
        grc_exclusion = temp("resources/mappability/grcExclusions.bb"),
        ucsc_problematic = temp("resources/mappability/ucsc_problematic.bb"),
        gencode_bed = temp("resources/ref_annot.bb"),
    shell:
        '''
        cp {input.encode_exclusion_remote} {output.encode_exclusion}
        cp {input.grc_exclusion_remote} {output.grc_exclusion}
        cp {input.ucsc_problematic_remote} {output.ucsc_problematic}
        cp {input.gencode_bed12_remote} {output.gencode_bed}
        '''

rule download_repeat_masker:
    """
    Download RepeatMasker annotation from UCSC for selected
    organism.
    """
    input:
        rmsk_remote = storage(
            "{}/{}/database/rmsk.txt.gz".format(
                config['UCSC_GOLDEN_PATH_URL'],
                'hg38' if config.get('organism', default_organism) == "human" else 'mm39'
            )
        )
    output:
        rmsk_annot = "resources/ucsc_repeatmasker_dump.txt.gz"
    shell:
        'cp {input.rmsk_remote} {output.rmsk_annot}'


rule download_exome_probesets:
    """
    Download common exome capture kits for WES analysis in human.
    Here we download kits from Twist.
    """
    input:
        twist_refseq_remote = storage(
            "{}/exomeProbesets/Twist_Exome_RefSeq_targets_hg38.bb".format(config['UCSC_URL'])),
        twist_core_exome_remote = storage(
            "{}/exomeProbesets/Twist_Exome_Target_hg38.bb".format(config['UCSC_URL'])),
        twist_comprehensive_exome_remote = storage(
            "{}/exomeProbesets/Twist_ComprehensiveExome_targets_hg38.bb".format(config['UCSC_URL'])),
        twist_exome2_remote = storage(
            "{}/exomeProbesets/TwistExome21.bb".format(config['UCSC_URL'])),
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
    Convert UCSC binary bigbed to ASCII bed files.
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
    conda:
        'envs/bigbedtobed.yaml'
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
    """
    Download resources from GATK bundle.
    """
    input:
        # Mills and 1000G gold standard
        mills_remote = storage(
            "{}/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz".format(config['GATK_URL'])),
        # HG38 known indels Homo_sapiens_assembly38.known_indels.vcf.gz
        known_indels_remote = storage(
            "{}/Homo_sapiens_assembly38.known_indels.vcf.gz".format(config['GATK_URL'])),
        # dbSNP release used by GATK (138)
        dbsnp_remote = storage(
            "{}/Homo_sapiens_assembly38.dbsnp138.vcf".format(config['GATK_URL'])),
        # 1000G high confidence SNPs
        thousand_genome_hc_remote = storage(
            "{}/1000G_phase1.snps.high_confidence.hg38.vcf.gz".format(config['GATK_URL'])),
        # 1000G Omni SNPs
        thousand_genome_omni_remote = storage(
            "{}/1000G_omni2.5.hg38.vcf.gz".format(config['GATK_URL'])),
        # HapMap germline SNPs 
        hapmap_remote = storage(
            "{}/hapmap_3.3.hg38.vcf.gz".format(config['GATK_URL'])),
    output:
        mills_vcf = "resources/gatk_bundle/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz",
        known_indels_vcf = "resources/gatk_bundle/Homo_sapiens_assembly38.known_indels.vcf.gz",
        gatk_dbsnp_gz = "resources/gatk_bundle/Homo_sapiens_assembly38.dbsnp138.vcf.gz",
        thousand_genome_hc_vcf = "resources/gatk_bundle/1000G_phase1.snps.high_confidence.hg38.vcf.gz",
        thousand_genome_omni_vcf = "resources/gatk_bundle/1000G_omni2.5.hg38.vcf.gz",
        hapmap_vcf = "resources/gatk_bundle/hapmap_3.3.hg38.vcf.gz"
    params:
        gatk_dbsnp = lambda wildcards, output:
            os.path.splitext(output.gatk_dbsnp_gz)[0]
    conda:
        'envs/bcftools.yaml'
    shell:
        '''
        cp {input.mills_remote} {output.mills_vcf}
        tabix -p vcf {output.mills_vcf}

        cp {input.known_indels_remote} {output.known_indels_vcf}
        tabix -p vcf {output.known_indels_vcf}

        cp {input.dbsnp_remote} {params.gatk_dbsnp}
        bgzip {params.gatk_dbsnp}
        tabix -p vcf {output.gatk_dbsnp_gz}

        cp {input.thousand_genome_hc_remote} {output.thousand_genome_hc_vcf}
        tabix -p vcf {output.thousand_genome_hc_vcf}

        cp {input.thousand_genome_omni_remote} {output.thousand_genome_omni_vcf}
        tabix -p vcf {output.thousand_genome_omni_vcf}

        cp {input.hapmap_remote} {output.hapmap_vcf}
        tabix -p vcf {output.hapmap_vcf}
        '''

rule download_dbsnp_human:
    """
    Download current dbSNP release from NCBI server.
    """
    input:
        dbsnp_remote = storage(
            "https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/00-common_all.vcf.gz"
        )
    output:
        dbsnp_vcf = temp("resources/germline_variants/00-common_all.vcf.gz"),
        dbsnp_tbi = temp("resources/germline_variants/00-common_all.vcf.gz.tbi")
    conda:
        'envs/bcftools.yaml'
    shell:
        '''
        cp {input.dbsnp_remote} {output.dbsnp_vcf}
        tabix -p vcf {output.dbsnp_vcf}
        '''

rule download_dbsnp_mouse:
    """
    Download dbSNP from ENSEMBL and convert chromosome names to GENCODE.
    """
    input:
        dbsnp_remote = storage(
            f"https://ftp.ensembl.org/pub/release-{ensembl_version}/variation/vcf/mus_musculus/mus_musculus.vcf.gz"
        ),
        chromosome_mapping_remote = storage(
            f"https://raw.githubusercontent.com/dpryan79/ChromosomeMappings/refs/heads/master/{config['genome-build']}_ensembl2{gencode_or_ucsc}.txt"
        )
    output:
        dbsnp_vcf = "resources/germline_variants/dbSNP_mouse.vcf.gz",
        chromosome_mapping = temp("resources/germline_variants/chromosome_mapping.txt"),
        dbsnp_tbi = "resources/germline_variants/dbSNP_mouse.vcf.gz.tbi"
    params:
        dbsnp_tmp = temp("resources/germline_variants/mus_musculus.vcf.gz"),
    conda:
        'envs/bcftools.yaml'
    shell:
        """
        cp {input.dbsnp_remote} {params.dbsnp_tmp}
        cp {input.chromosome_mapping_remote} {output.chromosome_mapping}
        tabix -p vcf {params.dbsnp_tmp}
        bcftools annotate --rename-chrs {output.chromosome_mapping} {params.dbsnp_tmp} -o {output.dbsnp_vcf}
        tabix -p vcf {output.dbsnp_vcf}
        rm {params.dbsnp_tmp}
        rm {params.dbsnp_tmp}.tbi
        """


rule prepare_dbsnp:
    """
    Filter dbSNP for standard chromosomes and change chromosome names from GENCODE to GENCODE.

    input:
        chrom_mapping (str): Path to chromosome mapping file from https://github.com/dpryan79/ChromosomeMappings
        vcf (str): Path to human dbSNP file
    output:
        dbsnp_vcf (str): Path to final dbSNP file
    """
    input:
        chrom_mapping = workflow.source_path('resources/GRCh38_ensembl2gencode.txt'),
        vcf = rules.download_dbsnp_human.output.dbsnp_vcf
    params:
        outdir = lambda wildcards, output: os.path.dirname(output.dbsnp_vcf)
    output:
        dbsnp_vcf = "resources/germline_variants/dbSNP_151.vcf.gz"
    conda:
        'envs/bcftools.yaml'
    script:
        'scripts/prepare_dbsnp.sh'

rule download_gnomad_exome:
    """
    Download gnomad exome based population SNPs from Google cloud storage
    per chromosome.
    """
    input:
        gnomad_remote = storage(
            "{}/{}/vcf/exomes/gnomad.exomes.v{}.sites.{{chromosome}}.vcf.bgz".format(
                config['GNOMAD_URL'],
                config['gnomad-release'],
                config['gnomad-release']
            )
        )
    output:
        vcf_file = temp("resources/germline_variants/gnomad_{chromosome}.vcf.tmp.bgz")
    shell:
        """
        cp {input.gnomad_remote} {output.vcf_file}
        """

rule af_only_gnomad:
    """
    Create allele frequency only (AF-only) VCF file required by MuTect2. This
    file inlcudes only germline variants and their overall population
    allele frequency.
    """
    input:
        gnomad = "resources/germline_variants/gnomad_{chromosome}.vcf.tmp.bgz",
        minimal_gnomad_header = workflow.source_path('resources/minimal_gnomad_header.txt')
    params:
        minimum_allele_frequency = config.get('minimum_allele_frequency', 0),
        tmp_vcf = "resources/germline_variants/gnomad_{chromosome}.vcf.tmp"
    output:
        vcf_file = temp("resources/germline_variants/gnomad_{chromosome}.vcf.gz"),
        vcf_file_index = temp("resources/germline_variants/gnomad_{chromosome}.vcf.gz.tbi")
    conda:
        'envs/bcftools.yaml'
    script:
        "scripts/make_AF_only_gnomad_vcf.sh"

rule bcftools_concat:
    """
    Concatenate chromosome level gnomad VCF into unified af-only VCF.
    """
    input:
        calls=[f"resources/germline_variants/gnomad_{x}.vcf.gz" for x in config['chrom-filter']],
    output:
        af_only_gnomad = "resources/germline_variants/af_only_gnomad_hg38.vcf.gz",
    log:
        "logs/all.log",
    params:
        uncompressed_bcf=False,
        extra="",  # optional parameters for bcftools concat (except -o)
    threads: 4
    resources:
        mem_mb=1024,
    wrapper:
        "v4.7.8/bio/bcftools/concat"

rule tabix_af_only_gnomad:
    """
    Create index for af-only VCF.
    """
    input:
        rules.bcftools_concat.output.af_only_gnomad,
    output:
        af_only_gnomad_tbi = "resources/germline_variants/af_only_gnomad_hg38.vcf.gz.tbi",
    log:
        "logs/tabix/af_only_gnomad_tbi.log",
    params:
        "-p vcf",
    wrapper:
        "v5.0.1/bio/tabix/index"

rule prepare_variants_for_contamination:
    """Create VCF file for GATK PileupSummaries calculation.

    As starting point, the previously generated gnomad AF only
    file is used and filtered.
    The resulting VCF file contains variants that match the 
    following criteria:
    * AF > 0.05
    * Biallelic
    * Filter: PASS
    * On chromosome 1
    These criteria were taken from the Mutect2 best practices
    workflow where 'variants_for_contamination' is described.
    https://github.com/broadinstitute/gatk/tree/master/scripts/mutect2_wdl
    """
    input:
        vcf_chr1 = "resources/germline_variants/gnomad_chr1.vcf.gz",
        vcf_chr1_tbi = "resources/germline_variants/gnomad_chr1.vcf.gz.tbi",
        minimal_gnomad_header = workflow.source_path('resources/minimal_gnomad_header.txt')
    output:
        prep_vcf = "resources/germline_variants/common_biallelic_chr1.vcf.gz",
        prep_vcf_tbi = "resources/germline_variants/common_biallelic_chr1.vcf.gz.tbi",
    params:
        tmp_vcf = "resources/germline_variants/common_biallelic_chr1.vcf",
    conda:
        'envs/bcftools.yaml'
    script:
        "scripts/prepare_variants_for_contamination.sh"

rule download_tcga_virus:
    """
    Download common virus (as defined by TCGA) genomes from GenBank.
    """
    input:
        tcga_virus = workflow.source_path('resources/tcga_viruses.tsv')
    params:
        output_prefix = lambda wildcards, output: os.path.dirname(output.tcga_virus)
    output:
        tcga_virus = "resources/viruses/tcga_virus_decoy.fasta"
    conda:
        'envs/efetch.yaml'
    shell:
        """
        while IFS=$'\\t' read -r name abbv genbank
        do
            efetch -db nuccore -format fasta -id "${{genbank}}" >> {params.output_prefix}/tcga_virus_decoy.fasta
        
        done < <(grep -v GenBank {input.tcga_virus}) 
        """

rule transcript_to_gene_mapping:
    """
    Generate a TSV file mapping Ensembl transcript ids to gene ids.
    """
    input:
        gtf = 'resources/ref_annot.gtf'
    output:
        tx2gene = 'resources/ref_annot_transcript2gene.tsv'
    conda:
        'envs/renv.yaml'
    script:
        'scripts/tx2gene.R'

rule gene_to_hgnc_mapping:
    """
    Generate a TSV file mapping Ensembl gene ids to HGNC gene symbols.
    """
    input:
        gtf = 'resources/ref_annot.gtf'
    output:
        mapping_table = 'resources/ref_annot_gene2symbol.tsv'
    conda:
        'envs/python.yaml'
    script:
        'scripts/get_annotation_data.py'

rule canonical_junction_list:
    """
    Extract canoncial splice junctions from GENCODE reference transcripts.
    """
    input:
        gtf = 'resources/ref_annot.gtf'
    output:
        canonical_juncs = 'resources/ref_annot_splice_sites.tsv'
    conda:
        'envs/renv.yaml'
    script:
        'scripts/canonical_splice_junctions.R'
