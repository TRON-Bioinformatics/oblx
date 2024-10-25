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
        fasta = get_genome_for_index_building
        gtf = config.get(
            'genome-gtf', 'resources/ref_annot.gtf'
        )
    params:
        genome_dir = lambda wildcards, output: os.path.dirname(output.genome_file),
        ram_byte = 48 * 1000000000,
        # if the index is built for a minimal genome
        genomesaindexnbases = '9' if config['minigenome'] else '14',
        sjdb_overhang = config.get('star-sjdb-overhang', 100)
    output:
        genome_file = "indices/star/Genome"
    threads: 18
    resources:
        mem_mb = 48 * 1000
    conda:
        'envs/star.yaml'
    log:
        'indices/star/star-index.log'
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
