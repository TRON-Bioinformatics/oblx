# These rules are based on the code found here:
# Original authors:
# License: 

rule genmap_index:
    input:
        genome = 'resources/ref_genome.fasta',
    params:
        idx_dir = lambda wildcards, output: os.path.dirname(output.idx_files[0])
    output:
        idx_files = [
            indices/genmap_index/index.ids.concat,
            indices/genmap_index/index.ids.limits,
            indices/genmap_index/index.info.concat,
            indices/genmap_index/index.info.limits,
            indices/genmap_index/index.lf.drp,
            indices/genmap_index/index.lf.drp.sbl,
            indices/genmap_index/index.lf.drs,
            indices/genmap_index/index.lf.drv,
            indices/genmap_index/index.lf.drv.sbl,
            indices/genmap_index/index.lf.pst,
            indices/genmap_index/index.rev.lf.drp,
            indices/genmap_index/index.rev.lf.drp.sbl,
            indices/genmap_index/index.rev.lf.drs,
            indices/genmap_index/index.rev.lf.drv,
            indices/genmap_index/index.rev.lf.drv.sbl,
            indices/genmap_index/index.rev.lf.pst,
            indices/genmap_index/index.sa.ind,
            indices/genmap_index/index.sa.len,
            indices/genmap_index/index.sa.val,
            indices/genmap_index/index.txt.concat,
            indices/genmap_index/index.txt.limits,]
    conda:
        "../envs/mappability.yml"
    resources:
        mem_mb = 50000
    shell:
        """
        rm -rf {params.idx_dir}
        genmap index -F {input.genome} -I {params.idx_dir} &> {log}
        """

rule genmap:
    input:
        genmap_idx = rules.genmap_index.output.idx_files
    output:
        bg = "indices/genmap_calc/genmap_k{readlength}_e{errors}/ref_genome.genmap.bedgraph",
        sorted_bg = "indices/genmap_calc/genmap_k{readlength}_e{errors}/ref_genome.genmap.sorted.bedgraph"
    params:
        outdir = lambda wildcards, output: os.path.dirname(output.sorted_bg)
        idx_dir = lambda wildcards, input: os.path.dirname(input.genmap_idx[0])
    conda:
        "../envs/mappability.yml"
    resources:
        mem_mb = 50000
    shell:
        """
        genmap map -K {wildcards.readlength} -E {wildcards.errors} -I {params.idx_dir} -O {params.outdir} -bg -T {threads} -v &>> {log}
        sort -k1,1 -k2,2n {output.bg} > {output.sorted_bg} 2>> {log}
        """

rule mappability_bed:
    input:
        bg = rules.genmap.output.sorted_bg
    output:
        callable_sites = "results/mappability/callable_sites/ref_genome_k{readlength}_e{errors}_callable_sites.bed",
        callable_sites_tmp = temp("results/mappability/callable_sites/ref_genome_k{readlength}_e{errors}_callable_sites.bed.tmp")
    conda:
        "../envs/mappability.yml"
    params:
        merge = config.get('mappability_merge', 50),
        mappability = config.get('mappability_min', 1),
        work_dir = lambda wildcards, output: os.path.dirname(output.callable_sites)
    resources:
        mem_mb = 10000
    shell:
        """
        awk 'BEGIN{{OFS="\\t";FS="\\t"}} {{ if($4>={params.mappability}) print $1,$2,$3 }}' {input.bg} > {output.callable_sites_tmp}
        bedtools merge -d {params.merge} -i {output.callable_sites_tmp} > {output.callable_sites}
        """
