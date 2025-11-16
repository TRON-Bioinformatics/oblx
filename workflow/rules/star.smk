rule star_index:
    """STAR index

    Rule to create a STAR index from the GENCODE annotation and
    DNA fasta file.

    input:
        fasta (string): Path to DNA fasta file
        gtf (string): Path to GTF file
    params:
        genomeDir (string): Path (dirname) to STAR index
        ramByte (int): Memory limit in byte for index generation
    output:
        genomeFile (string): Path to STAR index genome file
    """
    input:
        fasta = 'resources/ref_genome.fasta',
        gtf = config.get(
            'genome-gtf', 'resources/ref_annot.gtf'
        )
    params:
        genome_dir = lambda wildcards, output: os.path.dirname(output.genome_file),
        ram_byte = 48 * 1000000000,
        # see STAR parameter genomeSAindexNbases
        genomesaindexnbases = config.get("star-genome-sa-index-n-bases", '14'),
        sjdb_overhang = config.get('star-sjdb-overhang', 100)
    output:
        genome_file = "indices/star/Genome"
    threads: 16
    resources:
        mem_mb = 48 * 1000
    conda:
        '../envs/star.yaml'
    log:
        'logs/star/star-index.log'
    shell:
        'STAR '
        '--runMode genomeGenerate '
        '--runThreadN {threads} '
        '--limitGenomeGenerateRAM {params.ram_byte} '
        '--genomeDir {params.genome_dir} '
        '--genomeFastaFiles {input.fasta} '
        '--sjdbGTFfile {input.gtf} '
        '--sjdbOverhang {params.sjdb_overhang} '
        '--genomeSAindexNbases {params.genomesaindexnbases} '
        '> {log}'
