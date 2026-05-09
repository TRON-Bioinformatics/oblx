rule star_index:
    """
Create a STAR index from the GENCODE annotation file and reference DNA
sequence fasta file.

input:
    fasta (str): Path to reference DNA sequence fasta file.
    gtf (str): Path to reference annotation GTF file.
params:
    genome_dir (str): Path to the dir containing STAR index files.
    ram_byte (int): Memory limit in bytes for index generation, needs to
      match the amount provided by Snakemake.
    genomesaindexnbases (str): Genome SA index pre-indexing string length.
    sjdb_overhang (int): Splice junction database donor/acceptor sequence
      length per side of a splice junction.
output:
    genome_file (str): Path to STAR index genome file.
"""
    input:
        fasta="resources/ref_genome.fasta",
        gtf=config.get("genome-gtf", "resources/ref_annot.gtf"),
    output:
        genome_file="indices/star/Genome",
    log:
        "logs/star/star-index.log",
    conda:
        "../envs/star.yaml"
    container:
        config["container"].get("star")
    threads: 16
    resources:
        mem_mb=64 * 1000,  # higher than actual memory usage to consider container overhead
    params:
        genome_dir=lambda wildcards, output: os.path.dirname(output.genome_file),
        ram_byte=48 * 1000000000,
        # see STAR parameter genomeSAindexNbases
        genomesaindexnbases=config.get("star-genome-sa-index-n-bases", "14"),
        sjdb_overhang=config.get("star-sjdb-overhang", 100),
    shell:
        "STAR "
        "--runMode genomeGenerate "
        "--runThreadN {threads} "
        "--limitGenomeGenerateRAM {params.ram_byte} "
        "--genomeDir {params.genome_dir} "
        "--genomeFastaFiles {input.fasta} "
        "--sjdbGTFfile {input.gtf} "
        "--sjdbOverhang {params.sjdb_overhang} "
        "--genomeSAindexNbases {params.genomesaindexnbases} "
        "&> {log}"
