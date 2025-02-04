# Rules to mask assembly errors in GRCh38
# http://genomeref.blogspot.com/2021/07/one-of-these-things-doest-belong.html
# https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/references/README_GIAB_Mapping_References.md


rule mask_GRC_assembly_errors:
    input:
        genome = config.get(
            'genome-fasta', 'resources/ref_genome_primary.fasta'),
        grc_exclusion_bed = "resources/mappability/grcExclusions.bed"  
    output:
        masked_genome = "resources/ref_genome_grc_masked.fasta"
    conda:
        '../envs/bedtools.yaml'
    shell:
        'maskFastaFromBed '
        '-fi {input.genome} '
        '-bed {input.grc_exclusion_bed} '
        '-fo {output.masked_genome} '


rule mask_pseudoautosomal:
    input:
        genome = config.get(
            'genome-fasta', 'resources/ref_genome_grc_masked.fasta'),
        pseudoautosomal_regions_bed = workflow.source_path("../resources/GRCh38_pseudoautosomal_regions.bed")
    output:
        masked_genome = "resources/ref_genome_masked_final.fasta"
    conda:
        '../envs/bedtools.yaml'
    shell:
        'maskFastaFromBed '
        '-fi {input.genome} '
        '-bed {input.pseudoautosomal_regions_bed} '
        '-fo {output.masked_genome} '
