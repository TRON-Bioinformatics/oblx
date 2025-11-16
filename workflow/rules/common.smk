def get_genome_for_index_building(wildcards):
    """
    Get genome fasta file depending on organism
    For human we use a masked version while
    for murine models we use the primary assembly from
    Gencode
    """
    organism = config.get('organism', 'human')
    if organism == 'human':
        return "resources/ref_genome_masked_final.fasta"
    return "resources/ref_genome_primary.fasta"

def get_pull_resources_output(wildcards):
    """
    Collect final output of resource download workflow
    """
    
    organism = config.get('organism', 'human')
    # Files for human and mouse
    final_files = ['resources/ref_genome_primary.fasta',
                   'resources/ref_annot.gtf',
                   'resources/ref_transcripts.fasta',
                   'resources/ref_annot_metadata_SwissProt.tsv',
                   'resources/ref_annot_metadata_TrEMBL.tsv',
                   'resources/ref_genome_repeatmasker.bed',
                   'resources/ucsc_repeatmasker_dump.txt.gz',
                   'resources/ref_genome.dict',
                   'resources/ref_genome.fasta.fai',
                   'resources/exome_definition/ref_exome.bed',
                   'resources/ref_annot_splice_sites.tsv',
                   'resources/ref_annot_transcript2gene.tsv',
                   'resources/ref_annot_gene2symbol.tsv'
                   ]
    # Files specific to human
    if organism == "human":
        final_files.extend([
            "resources/mappability/encode_exclusion.bed",
            "resources/mappability/grcExclusions.bed",
            "resources/mappability/ucsc_problematic.bed",
            "resources/ref_annot.bed",
            "resources/exome_definition/twist_refseq.bed",
            "resources/exome_definition/twist_core_exome.bed",
            "resources/exome_definition/twist_comprehensive_exome.bed",
            "resources/exome_definition/twist_exome2.bed",
            "resources/viruses/tcga_virus_decoy.fasta",
            "resources/germline_variants/af_only_gnomad_hg38.vcf.gz",
            "resources/germline_variants/af_only_gnomad_hg38.vcf.gz.tbi",
            "resources/germline_variants/common_biallelic_chr1.vcf.gz",
            "resources/germline_variants/common_biallelic_chr1.vcf.gz.tbi",
            "resources/gatk_bundle/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz",
            "resources/gatk_bundle/Homo_sapiens_assembly38.known_indels.vcf.gz",
            "resources/gatk_bundle/Homo_sapiens_assembly38.dbsnp138.vcf.gz",
            "resources/gatk_bundle/1000G_phase1.snps.high_confidence.hg38.vcf.gz",
            "resources/gatk_bundle/1000G_omni2.5.hg38.vcf.gz",
            "resources/gatk_bundle/hapmap_3.3.hg38.vcf.gz",
            "resources/germline_variants/dbSNP_151.vcf.gz",
            "resources/ref_genome.dict",
            "resources/ref_genome.fasta.fai"
        ])

    # Files specific to mouse
    if organism == "mouse":
        final_files.extend([
            "resources/germline_variants/dbSNP_mouse.vcf.gz",
            "resources/germline_variants/dbSNP_mouse.vcf.gz.tbi"
        ])
    
    return final_files

def get_build_indices_output(wildcards):
    """
    Collect final output of build indices workflow
    """
    organism = config.get('organism', 'human')

    # bwa index files
    final_files = multiext(
            "indices/bwa/ref_genome.fasta", 
            ".0123", 
            ".amb", 
            ".ann",
            ".bwt.2bit.64",
            ".pac"
        )
    final_files.append('indices/bwa/ref_genome.fasta.fai')

    # salmon files
    final_files.extend(multiext(
            "indices/salmon/transcriptome_index/",
            "complete_ref_lens.bin",
            "ctable.bin",
            "ctg_offsets.bin",
            "duplicate_clusters.tsv",
            "info.json",
            "mphf.bin",
            "pos.bin",
            "pre_indexing.log",
            "rank.bin",
            "refAccumLengths.bin",
            "ref_indexing.log",
            "reflengths.bin",
            "refseq.bin",
            "seq.bin",
            "versionInfo.json",))
    final_files.append('indices/salmon/requant_index/transcripts.fa')

    # snpeff files
    final_files.append(os.path.abspath(os.path.join(
            'indices/snpeff/data/',
            f'{config.get("genome-build", default_build)}.{config.get("release", default_release)}',
            'snpEffectPredictor.bin'
        )))

    # STAR files
    final_files.append("indices/star/Genome")

    # splice2neo files
    final_files.append('indices/R/ref_annot_txdb.sqlite')
    final_files.append('indices/R/ref_genome.2bit',)
    final_files.append('indices/R/ref_transcripts.Rds')
    final_files.append('indices/R/ref_transcript_ranges.Rds')
    final_files.append('indices/R/ref_cds.Rds')

    # kallisto files
    final_files.append('indices/kallisto/ref_transcript.idx')

    return final_files