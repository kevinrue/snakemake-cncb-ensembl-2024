rule alevin_build_reference_index:
    input:
        genome="resources/genome/genome.fa.gz",
        gtf="resources/genome/genome.gtf.gz",
    output:
        index=directory("resources/genome/index/alevin"),
    log:
        out="logs/alevin/build_reference_index.out",
        err="logs/alevin/build_reference_index.err",
    threads: 16
    resources:
        mem="8G",
        runtime="2h",
    params:
        rlen=config["simpleaf"]["index"]["rlen"]
    shell:
        "jobdir=$(pwd) &&"
        " cd $TMPDIR &&"
        " export ALEVIN_FRY_HOME=af_home &&"
        " simpleaf set-paths &&"
        " gunzip -c $jobdir/{input.genome} > tmp_alevin_index.fa  &&"
        " simpleaf index"
        " --output $jobdir/{output.index}"
        " --fasta tmp_alevin_index.fa"
        " --gtf $jobdir/{input.gtf}"
        " --rlen {params.rlen}"
        " --threads {threads}"
        " --use-piscem"
        " > $jobdir/{log.out} 2> $jobdir/{log.err}"

# Function used by rule: alevin_quant
def get_alevin_quant_input_fastqs(wildcards):
    sample_fastqs_info=SAMPLES[SAMPLES['sample_name'] == wildcards.sample].filter(items=['directory', 'R1', 'R2'])
    fq1=[os.path.join(os.path.realpath(sample_fastqs_info['directory'][i]), sample_fastqs_info['R1'][i]) for i in sample_fastqs_info.index]
    fq2=[os.path.join(os.path.realpath(sample_fastqs_info['directory'][i]), sample_fastqs_info['R2'][i]) for i in sample_fastqs_info.index]
    return {
        'fq1': fq1,
        'fq2': fq2,
    }

rule alevin_quant:
    input:
        unpack(get_alevin_quant_input_fastqs),
        index="resources/genome/index/alevin",
    output:
        directory("results/alevin/{sample}"),
    params:
        reads1=lambda wildcards, input: ','.join(input.fq1),
        reads2=lambda wildcards, input: ','.join(input.fq2),
    log:
        out="logs/alevin/quant/{sample}.out",
        err="logs/alevin/quant/{sample}.err",
    threads: 16
    resources:
        mem="16G",
        runtime="4h",
    shell:
        "jobdir=$(pwd) &&"
        " cd $TMPDIR &&"
        " export ALEVIN_FRY_HOME=af_home &&"
        " simpleaf set-paths &&"
        " simpleaf quant"
        " --reads1 {params.reads1}"
        " --reads2 {params.reads2}"
        " --index $jobdir/{input.index}/index"
        " --chemistry 10xv4-3p --resolution cr-like --expected-ori fw --unfiltered-pl" # from tutorial, to be confirmed
        " --t2g-map $jobdir/{input.index}/index/t2g_3col.tsv"
        " --threads {threads}"
        " --output alevin_quant_{wildcards.sample}"
        " > $jobdir/{log.out} 2> $jobdir/{log.err} &&"
        " mv alevin_quant_{wildcards.sample} $jobdir/{output}"

rule alevin_all_rds:
    input:
        expand("results/alevin/{sample}", sample=SAMPLES['sample_name'].unique()),
    output:
        rds="results/sce/all.rds",
    threads: 16
    resources:
        mem="128G",
        runtime="1h",
    conda:
        "../../conda/bioconductor_3_20.yaml"
    script:
        "../../scripts/simpleaf_merge.R"

rule alevin_all_hdf5:
    input:
        rds="results/sce/all.rds",
    output:
        hdf5=directory("results/hdf5/all"),
    resources:
        mem="64G",
        runtime="6h",
    conda:
        "../../conda/bioconductor_3_20.yaml"
    script:
        "../../scripts/simpleaf_hdf5.R"

rule scuttle_lognorm:
    input:
        rds="results/sce/all.rds",
    output:
        rds="results/sce/lognorm.rds",
    params:
        min_umis=config["barcode_filters"]["min_umis"],
        min_genes=config["barcode_filters"]["min_genes"],        
    resources:
        mem="128G",
        runtime="1h",
    threads: 32
    conda:
        "../../conda/bioconductor_3_20.yaml"
    script:
        "../../scripts/scuttle_lognorm.R"

rule scran_hvgs:
    input:
        rds="results/sce/lognorm.rds",
    output:
        tsv="results/model_gene_var/decomposed_variance.tsv",
        fit="results/model_gene_var/fit.pdf",
        hvgs="results/model_gene_var/variable_genes.txt",
    params:
        hvgs_prop=config["variable_genes"]["proportion"],
    resources:
        mem="128G",
        runtime="30m",
    threads: 32
    conda:
        "../../conda/bioconductor_3_20.yaml"
    script:
        "../../scripts/scran_modelgenevar.R"

rule scran_fixed_pca:
    input:
        sce="results/sce/lognorm.rds",
        hvgs="results/model_gene_var/variable_genes.txt",
    output:
        var_explained="results/fixed_pca/var_explained.pdf",
        sce="results/sce/pca.rds",
    params:
        rank=config["fixed_pca"]["rank"],
    resources:
        mem="256G",
        runtime="6h",
    threads: 24
    conda:
        "../../conda/bioconductor_3_20.yaml"
    script:
        "../../scripts/scran_fixedpca.R"

rule scran_umap:
    input:
        sce="results/sce/pca.rds",
    output:
        sce="results/sce/umap.rds",
    params:
        pcs=config["umap"]["n_pcs"],
    resources:
        mem="20G",
        runtime="1h",
    threads: 32
    conda:
        "../../conda/bioconductor_3_20.yaml"
    script:
        "../../scripts/scater_umap.R"
