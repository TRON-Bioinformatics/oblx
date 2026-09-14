"""
Snakemake workflow to pull all required reference files for Ensembl.
"""


rule pull_resources:
    input:
        get_pull_resources_output,


rule download_ensembl_transcripts:
    """Rule to download Ensembl transcript files."""
    input:
        cdna_remote=storage(
            "{}/release-{}/fasta/{}/cdna/{}.{}.cdna.all.fa.gz".format(
                config["ensembl_url"],
                config["release"],
                config["organism"].lower(),
                config["organism"],
                config["genome_build"],
            )
        ),
        ncrna_remote=storage(
            "{}/release-{}/fasta/{}/ncrna/{}.{}.ncrna.fa.gz".format(
                config["ensembl_url"],
                config["release"],
                config["organism"].lower(),
                config["organism"],
                config["genome_build"],
            )
        ),
    output:
        fasta=temp("resources/ref_transcripts.fasta.gz"),
    log:
        "logs/pull_resources/download_ensembl_transcripts.log",
    benchmark:
        "benchmarks/pull_resources/download_ensembl_transcripts.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        exec &> "{log}"
        cp "{input.cdna_remote}" "{output.fasta}"
        cp "{input.ncrna_remote}" "{output.fasta}"
        """


rule gunzip_ensembl_transcripts_fasta:
    """Rule to gunzip the downloaded Ensembl transcripts fasta file.

input:
    fasta (string): Path to gzipped fasta file
output:
        fasta (string): Path to unzipped fasta file
"""
    input:
        cdna=rules.download_ensembl_transcripts.output.fasta,
        ncrna=rules.download_ensembl_transcripts.output.fasta,
    output:
        cdna="resources/cdna_ref_transcripts.fasta",
        ncrna="resources/ncrna_ref_transcripts.fasta",
    log:
        "logs/pull_resources/gunzip_ensembl_transcripts_fasta.log",
    benchmark:
        "benchmarks/pull_resources/gunzip_ensembl_transcripts_fasta.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        exec &> "{log}"
        gunzip --stdout "{input.cdna}" > "{output.cdna}"
        gunzip --stdout "{input.ncrna}" > "{output.ncrna}"
        """


rule concat_ensembl_transcripts_fasta:
    """Rule to concatenate the gunzipped Ensembl transcripts fasta files."""
    input:
        cdna="resources/cdna_ref_transcripts.fasta",
        ncrna="resources/ncrna_ref_transcripts.fasta",
    output:
        fasta="resources/ref_transcripts.fasta",
    log:
        "logs/pull_resources/concat_ensembl_transcripts_fasta.log",
    benchmark:
        "benchmarks/pull_resources/concat_ensembl_transcripts_fasta.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        exec &> "{log}"
        cat "{input.cdna}" "{input.ncrna}" > "{output.fasta}"
        """


rule download_ensembl_fasta:
    """Rule to download reference fasta from Ensembl.

Downloads the required reference genome (fasta) and
transcript annotation (gtf) from Ensembl ftp server

input:
    fasta_remote (storage): RemoteProvider pointing to fasta on Ensembl ftp
output:
    fasta (string): Path to gzipped fasta file

"""
    input:
        fasta_remote=storage(
            "{}/release-{}/fasta/{}/dna/{}.{}.{}.{{chr}}.fa.gz".format(
                config["ensembl_url"],
                config["release"],
                config["organism"].lower(),
                config["organism"],
                config["genome_build"],
                config["ensembl_genome_type"],
            )
        ),
    output:
        fasta=temp(
            "resources/ENSEMBL/{}.{}.{}.{{chr}}.fa.gz".format(
                config["organism"].lower(),
                config["genome_build"],
                config["release"],
            )
        ),
    log:
        "logs/pull_resources/download_ensembl_data_{chr}.log",
    benchmark:
        "benchmarks/pull_resources/download_ensembl_data_{chr}.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        exec &> "{log}"
        cp "{input.fasta_remote}" "{output.fasta}"
        """


rule gunzip_ensembl_fasta:
    """Rule to gunzip the downloaded Ensembl fasta file.

input:
    fasta (string): Path to gzipped fasta file
output:
        fasta (string): Path to unzipped fasta file
"""
    input:
        fasta=rules.download_ensembl_fasta.output.fasta,
    output:
        fasta=temp(
            "resources/ENSEMBL/uncompressed/{}.{}.{}.{{chr}}.fa".format(
                config["organism"].lower(),
                config["genome_build"],
                config["release"],
            )
        ),
    log:
        "logs/pull_resources/gunzip_ensembl_fasta_{chr}.log",
    benchmark:
        "benchmarks/pull_resources/gunzip_ensembl_fasta_{chr}.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        exec &> "{log}"
        gunzip --stdout "{input.fasta}" > "{output.fasta}"
        """


rule rename_ensembl_fasta_header:
    """Rule to rename the headers of the Ensembl fasta file."""
    input:
        fasta=rules.gunzip_ensembl_fasta.output.fasta,
    output:
        fasta=temp(
            "resources/ENSEMBL/renamed/{}.{}.{}.{{chr}}.fa".format(
                config["organism"].lower(),
                config["genome_build"],
                config["release"],
            )
        ),
    log:
        "logs/pull_resources/rename_ensembl_fasta_header_{chr}.log",
    benchmark:
        "benchmarks/pull_resources/rename_ensembl_fasta_header_{chr}.txt"
    conda:
        "../envs/seqkit.yaml"
    container:
        config["container"].get("seqkit")
    params:
        new_chr=lambda wildcards: ensembl_to_gencode_chr_name(wildcards.chr),
    shell:
        """
        exec &> "{log}"
        seqkit replace --pattern '^{wildcards.chr}.*' --replacement '{params.new_chr}' '{input.fasta}' > '{output.fasta}'
        """


rule combine_ensembl_fastas:
    """Rule to combine individual chromosome fasta files into a single fasta file."""
    input:
        fasta_files=expand(
            "resources/ENSEMBL/renamed/{}.{}.{}.{{chr}}.fa".format(
                config["organism"].lower(),
                config["genome_build"],
                config["release"],
            ),
            chr=config["chrom_filter"],
        ),
    output:
        combined_fasta="resources/ref_genome_primary.fasta",
    log:
        "logs/pull_resources/combine_ensembl_fastas.log",
    benchmark:
        "benchmarks/pull_resources/combine_ensembl_fastas.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        exec &> "{log}"
        cat {input.fasta_files} > "{output.combined_fasta}"
        """


rule download_ensembl_gtf:
    """Rule to download annotation data from Ensembl.

Downloads the required transcript annotation (gtf) from Ensembl ftp server

input:
    gtf_remote (storage): RemoteProvider pointing to gtf on Ensembl ftp
output:
    gtf (string): Path to gzipped gtf file

"""
    input:
        gtf_remote=storage(
            "{}/release-{}/gtf/{}/{}.{}.{}.chr.gtf.gz".format(
                config["ensembl_url"],
                config["release"],
                config["organism"].lower(),
                config["organism"],
                config["genome_build"],
                config["release"],
            )
        ),
    output:
        gtf=temp("resources/ref_annot_ensembl.gtf.gz"),
    log:
        "logs/pull_resources/download_ensembl_gtf.log",
    benchmark:
        "benchmarks/pull_resources/download_ensembl_gtf.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        exec &> "{log}"
        cp "{input.gtf_remote}" "{output.gtf}"
        """


rule gunzip_ensembl_gtf:
    """Rule to gunzip the downloaded Ensembl GTF file.

input:
    gtf (string): Path to gzipped gtf file
output:
        gtf (string): Path to unzipped gtf file
"""
    input:
        gtf="resources/ref_annot_ensembl.gtf.gz",
    output:
        gtf=temp("resources/ref_annot_ensembl.gtf"),
    log:
        "logs/pull_resources/gunzip_ensembl_gtf.log",
    benchmark:
        "benchmarks/pull_resources/gunzip_ensembl_gtf.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        exec &> "{log}"
        gunzip --stdout "{input.gtf}" > "{output.gtf}"
        """


rule rename_chrom_names_gtf:
    """Rule to rename chromosome names in the downloaded Ensembl GTF file.

The Ensembl chromosome names are replaced by the GENCODE "chr" convention.

input:
    gtf (string): Path to unzipped gtf file
output:
        gtf (string): Path to GTF file with renamed chromosome names
"""
    input:
        gtf="resources/ref_annot_ensembl.gtf",
        script=workflow.source_path("../scripts/ensembl2gencode_gtf.sh"),
    output:
        gtf="resources/ref_annot.gtf",
    log:
        "logs/pull_resources/rename_chrom_names_gtf.log",
    benchmark:
        "benchmarks/pull_resources/rename_chrom_names_gtf.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        exec &> "{log}"
        bash {input.script} {input.gtf} {output.gtf}
        """


rule download_ensembl_snp_vcf:
    """Rule to download the SNP VCF file from Ensembl."""
    input:
        url=storage(
            "{}release-{}/variation/vcf/{}/{}.vcf.gz".format(
                config["ensembl_url"],
                config["release"],
                config["organism"].lower(),
                config["organism"].lower(),
            )
        ),
    output:
        vcf=temp("resources/snp_ensembl.vcf.gz"),
    log:
        "logs/pull_resources/download_snp_vcf.log",
    benchmark:
        "benchmarks/pull_resources/download_snp_vcf.txt"
    conda:
        "../envs/shellutils.yaml"
    container:
        config["container"].get("shell_utils")
    shell:
        """
        exec &> "{log}"
        cp "{input.url}" "{output.vcf}"
        """


rule prepare_ensembl_snp_vcf:
    input:
        dbsnp_vcf=rules.download_ensembl_snp_vcf.output.vcf,
        chromosome_mapping=workflow.source_path(config["chromosome_mapping_file"]),
    output:
        dbsnp_vcf="resources/germline_variants/{}.vcf.gz".format(
            config["organism"].lower()
        ),
        dbsnp_vcf_tbi="resources/germline_variants/{}.vcf.gz.tbi".format(
            config["organism"].lower()
        ),
        chromosome_mapping="resources/germline_variants/chromosome_mapping.txt",
    log:
        "logs/pull_resources/prepare_ensembl_snp_vcf.log",
    benchmark:
        "benchmarks/pull_resources/prepare_ensembl_snp_vcf.txt"
    conda:
        "../envs/bcftools.yaml"
    container:
        config["container"].get("bcftools")
    params:
        dbsnp_tmp=temp(
            "resources/germline_variants/{}.tmp.vcf.gz".format(
                config["organism"].lower()
            )
        ),
        chromosomes=",".join(config.get("chrom_filter", [])),
    shell:
        """
        exec &> "{log}"
        ls -lah
        cp "{input.dbsnp_vcf}" "{params.dbsnp_tmp}"
        cp "{input.chromosome_mapping}" "{output.chromosome_mapping}"
        tabix -p vcf "{params.dbsnp_tmp}"

        bcftools annotate \
            --rename-chrs "{output.chromosome_mapping}" \
            --regions "{params.chromosomes}" \
            -O z \
            -o "{output.dbsnp_vcf}" \
            "{params.dbsnp_tmp}"

        tabix -p vcf "{output.dbsnp_vcf}"
        rm "{params.dbsnp_tmp}"
        rm "{params.dbsnp_tmp}.tbi"
        """
