
rule hisat2_snps_haplotypes:
    """
Generate hisat2 snp and haplotype files for genome indexing.
"""
    input:
        fasta="resources/ref_genome.fasta",
        vcf=get_organism_germline_variants,
    output:
        haplotype="indices/hisat2/genome.haplotype",
        snp="indices/hisat2/genome.snp",
    log:
        "logs/hisat2/hisat2_snps_haplotypes.log",
    benchmark:
        "benchmarks/hisat2/hisat2_snps_haplotypes.txt"
    conda:
        "../envs/hisat2.yaml"
    container:
        config["container"].get("hisat2")
    threads: 1
    params:
        prefix=lambda wildcards, output: os.path.splitext(output.haplotype)[0],
    shell:
        """
        hisat2_extract_snps_haplotypes_VCF.py \
            "{input.fasta}" \
            "{input.vcf}" \
            "{params.prefix}" \
            &> "{log}"
        """


rule hisat2_ss:
    """
Generate hisat2 splice site file for genome indexing.
"""
    input:
        gtf=config.get("genome-gtf", "resources/ref_annot.gtf"),
    output:
        ss="indices/hisat2/genome.ss",
    log:
        "logs/hisat2/hisat2_ss.log",
    benchmark:
        "benchmarks/hisat2/hisat2_ss.txt"
    conda:
        "../envs/hisat2.yaml"
    container:
        config["container"].get("hisat2")
    shell:
        """
        hisat2_extract_splice_sites.py \
            "{input.gtf}" \
            > "{output.ss}" \
            2> "{log}"
        """


rule hisat2_exons:
    """
Generate hisat2 exon file for genome indexing.
"""
    input:
        gtf=config.get("genome-gtf", "resources/ref_annot.gtf"),
    output:
        exons="indices/hisat2/genome.exon",
    log:
        "logs/hisat2/hisat2_exons.log",
    benchmark:
        "benchmarks/hisat2/hisat2_exons.txt"
    conda:
        "../envs/hisat2.yaml"
    container:
        config["container"].get("hisat2")
    shell:
        """
        hisat2_extract_exons.py \
            "{input.gtf}" \
            > "{output.exons}" \
            2> "{log}"
        """


# FIXME Use large index only for mouse.
rule hisat2_index:
    """
Generate hisat2 HGFM index including SNPs and splice-sites.
"""
    input:
        fasta="resources/ref_genome.fasta",
        snp="indices/hisat2/genome.snp",
        haplotype="indices/hisat2/genome.haplotype",
        ss="indices/hisat2/genome.ss",
        exon="indices/hisat2/genome.exon",
    output:
        multiext(
            "indices/hisat2/genome",
            ".1.ht2l",
            ".2.ht2l",
            ".3.ht2l",
            ".4.ht2l",
            ".5.ht2l",
            ".6.ht2l",
            ".7.ht2l",
            ".8.ht2l",
        ),
    log:
        "logs/hisat2/hisat2_index.log",
    benchmark:
        "benchmarks/hisat2/hisat2_index.txt"
    conda:
        "../envs/hisat2.yaml"
    container:
        config["container"].get("hisat2")
    threads: 16
    resources:
        # The job itself will reserve 2GB of the memory to account for
        # memory overhead in the case of container usage.
        # hisat2 recommends at least 160 GB in this step for human genome
        # indexing, so we set the memory limit to 200 GB to be safe.
        # During testing, 170GB turned out to not be sufficient.
        mem_mb=lambda _: 250 * 1e3 if config["organism"] == "mouse" else 200 * 1e3,
    params:
        # Remove trailing .ht2 and number to get the correct prefix for hisat2-build
        prefix=lambda wildcards, output: os.path.splitext(
            os.path.splitext(output[0])[0]
        )[0],
    shell:
        """
        # Due to the large amount of SNPs for the mouse genome, we need to use
        # a large hisat2 index, else it can't deal with such large numbers.
        hisat2-build \
            --large-index \
            --threads {threads} \
            "{input.fasta}" \
            --snp "{input.snp}" \
            --haplotype "{input.haplotype}" \
            --ss "{input.ss}" \
            --exon "{input.exon}" \
            "{params.prefix}" \
            &> "{log}"
        """
