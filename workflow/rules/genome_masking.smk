# Rules to mask assembly errors in GRCh38
# http://genomeref.blogspot.com/2021/07/one-of-these-things-doest-belong.html
# https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/references/README_GIAB_Mapping_References.md


rule mask_GRC_assembly_errors:
    """
    Mask assembly errors in hg38 build of the human genome.

    input:
        genome (str): Path to the fasta file that should be masked.
        grc_exclusion_bed (str): Path to GRC exclusion regions.
    output:
        masked_genome (str): Path to masked fasta file.
    """
    input:
        genome = config.get(
            'genome-fasta', 'resources/ref_genome_primary.fasta'),
        grc_exclusion_bed = "resources/mappability/grcExclusions.bed"
    output:
        masked_genome = "resources/ref_genome_grc_masked.fasta"
    conda:
        '../envs/bedtools.yaml'
    container:
        config['container'].get('bedtools')
    shell:
        'maskFastaFromBed '
        '-fi {input.genome} '
        '-bed {input.grc_exclusion_bed} '
        '-fo {output.masked_genome} '


rule mask_pseudoautosomal:
    """
    Mask pseudoautosomal regions in hg38 build of the human genome.

    input:
        genome (str): Path to the fasta file that should be masked.
        pseudoautosomal_regions_bed (str): Path to BED file of chrY regions.
    output:
        masked_genome (str): Path to masked fasta file.
    """
    input:
        genome = config.get(
            'genome-fasta', 'resources/ref_genome_grc_masked.fasta'),
        pseudoautosomal_regions_bed = PA_REGION_BED_PATH
    output:
        masked_genome = "resources/ref_genome_masked_final.fasta"
    conda:
        '../envs/bedtools.yaml'
    container:
        config['container'].get('bedtools')
    shell:
        'maskFastaFromBed '
        '-fi {input.genome} '
        '-bed {input.pseudoautosomal_regions_bed} '
        '-fo {output.masked_genome} '
