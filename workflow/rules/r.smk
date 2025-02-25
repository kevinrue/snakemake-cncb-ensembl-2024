rule simpleaf_quant_rds:
    input:
        simpleaf="results/simpleaf/quant/{sample}"
    output:
        sce="results/fishpond/{sample}.rds"
    threads: 2
    resources:
        mem="32G",
        runtime="20m",
    conda:
        "../../conda/conda.yaml"
    script:
        "../../scripts/simpleaf_counts_rds.R"

rule simpleaf_quant_merge_rds:
    input:
        expand("results/fishpond/{sample}.rds", sample=SAMPLES['sample_name'].unique()),
    output:
        sce="results/fishpond/_all.rds",
    threads: 2
    resources:
        mem="128G",
        runtime="1h",
    conda:
        "../../conda/conda.yaml"
    script:
        "../../scripts/simpleaf_merge.R"

rule simpleaf_lower_umi_per_sample:
    input:
        sce="results/fishpond/{sample}.rds",
    output:
        txt="results/umi_min_expected/{sample}.txt"
    params:
        expect_cells=lambda wildcards, input: SAMPLES['expect_cells'][wildcards.sample],
    threads: 2
    resources:
        mem="16G",
        runtime="10m",
    conda:
        "../../conda/conda.yaml"
    script:
        "../../scripts/lower_umi_sample.R"

rule dropletutils_barcode_ranks:
    input:
        sce="results/fishpond/{sample}.rds",
        lower="results/umi_min_expected/{sample}.txt",
    output:
        rds="results/barcodeRanks/{sample}.rds",
    conda:
        "../../conda/conda.yaml"
    threads: 12
    resources:
        mem="64G",
        runtime="30m",
    script:
        "../../scripts/dropletutils_barcoderanks.R"

rule dropletutils_emptydrops_per_sample:
    input:
        sce="results/fishpond/{sample}.rds",
        barcoderank="results/barcodeRanks/{sample}.rds",
        ignore="results/umi_min_expected/{sample}.txt"
    output:
        rds="results/emptyDrops/result/{sample}.rds",
    params:
        expect_cells=lambda wildcards, input: SAMPLES['expect_cells'][wildcards.sample],
        lower=config["emptydrops"]["lower"],
        niters=config["emptydrops"]["niters"],
    conda:
        "../../conda/conda.yaml"
    threads: 12
    resources:
        mem="64G",
        runtime="30m",
    script:
        "../../scripts/dropletutils_emptydrops_sample.R"

rule sce_after_emptydrops:
    input:
        sce="results/fishpond/{sample}.rds",
        emptydrops="results/emptyDrops/result/{sample}.rds",
    output:
        rds="results/emptyDrops/sce/{sample}.rds",
    params:
        fdr=config["emptydrops"]["fdr"],
    conda:
        "../../conda/conda.yaml"
    threads: 12
    resources:
        mem="64G",
        runtime="30m",
    script:
        "../../scripts/apply_emptydrops.R"

rule filter_mitochondria:
    input:
        sce="results/emptyDrops/sce/{sample}.rds",
    output:
        sce="results/filter_mitochondria/{sample}.rds",
    params:
        pct_max=config["filters"]["barcodes"]["mt_pct_max"],
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="16G",
        runtime="30m",
    script:
        "../../scripts/filter_mitochondria.R"

rule scran_hvgs_sample:
    input:
        sce="results/filter_mitochondria/{sample}.rds",
    output:
        tsv="results/model_gene_var/{sample}/decomposed_variance.tsv",
        fit="results/model_gene_var/{sample}/fit.pdf",
        hvgs="results/model_gene_var/{sample}/variable_genes.txt",
    params:
        hvgs_prop=config["variable_genes"]["proportion"],
    resources:
        mem="16G",
        runtime="30m",
    threads: 16
    conda:
        "../../conda/conda.yaml"
    script:
        "../../scripts/scran_modelgenevar.R"

rule simpleaf_counts_all_rds:
    input:
        expand("results/filter_mitochondria/{sample}.rds", sample=SAMPLES['sample_name'].unique()),
    output:
        sce="results/filter_mitochondria/_all.rds",
    threads: 2
    resources:
        mem="128G",
        runtime="30m",
    conda:
        "../../conda/conda.yaml"
    script:
        "../../scripts/simpleaf_merge.R"

rule simpleaf_counts_hdf5:
    input:
        sce="results/filter_mitochondria/_all.rds"
    output:
        sce=directory("results/filter_mitochondria/hdf5"),
    resources:
        mem="64G",
        runtime="6h",
    conda:
        "../../conda/conda.yaml"
    script:
        "../../scripts/simpleaf_hdf5.R"

rule scuttle_lognormcounts:
    input:
        sce="results/filter_mitochondria/_all.rds"
    output:
        sce="results/filter_mitochondria/_logcounts.rds",
    resources:
        mem="64G",
        runtime="30m",
    threads: 32
    conda:
        "../../conda/conda.yaml"
    script:
        "../../scripts/scuttle_lognormcounts.R"

rule filtered_gene_ids:
    input:
        sce="results/filter_mitochondria/_logcounts.rds",
    output:
        txt="results/filter_mitochondria/_logcounts_rownames.txt"
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="64G",
        runtime="30m",
    script:
        "../../scripts/sce_rownames.R"

rule scran_modelgenevar_block:
    input:
        sce="results/filter_mitochondria/_logcounts.rds",
    output:
        rds="results/model_gene_var/modelGeneVar.rds",
    params:
        block=config["variable_genes"]["block"],
        hvgs_prop=config["variable_genes"]["proportion"],
    resources:
        mem="64G",
        runtime="15m",
    threads: 32
    conda:
        "../../conda/conda.yaml"
    script:
        "../../scripts/scran_modelgenevar_block.R"

rule scran_top_hvgs:
    input:
        rds="results/model_gene_var/modelGeneVar.rds",
    output:
        hvgs="results/model_gene_var/variable_genes.txt",
    params:
        prop=config["variable_genes"]["proportion"],
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="8G",
        runtime="10m",
    script:
        "../../scripts/scran_top_hvgs.R"

rule batchelor_fastmnn:
    input:
        sce="results/filter_mitochondria/_logcounts.rds",
        hvgs="results/model_gene_var/variable_genes.txt",
    output:
        sce="results/fastmnn/sce.rds",
    params:
        batch=config["fastmnn"]["batch"],
        d=config["fastmnn"]["d"],
        k=config["fastmnn"]["k"],
    resources:
        mem="64G",
        runtime="3h",
    threads: 32
    conda:
        "../../conda/conda.yaml"
    script:
        "../../scripts/batchelor_fastmnn.R"

rule cluster_after_integration:
    input:
        rds="results/fastmnn/sce.rds",
    output:
        rds="results/fastmnn/clusters.rds",
    params:
        kmeans_centers=config["fastmnn"]["cluster"]["kmeans"]["centers"],
        nn_k=config["fastmnn"]["cluster"]["nn"]["k"],
    resources:
        mem="8G",
        runtime="15m",
    threads: 2
    conda:
        "../../conda/conda.yaml"
    script:
        "../../scripts/cluster_after_integration.R"

rule scran_umap_after_integration:
    input:
        sce="results/fastmnn/sce.rds",
    output:
        sce="results/fastmnn/umap.rds",
    params:
        n_pcs=config["fastmnn"]["umap"]["n_pcs"],
    resources:
        mem="64G",
        runtime="3h",
    threads: 32
    conda:
        "../../conda/conda.yaml"
    script:
        "../../scripts/scater_umap_after_integration.R"

rule scran_fixed_pca:
    input:
        sce="results/filter_mitochondria/_logcounts.rds",
        hvgs="results/model_gene_var/variable_genes.txt",
    output:
        var_explained="results/fixed_pca/var_explained.pdf",
        sce="results/filter_mitochondria/_pca.rds",
    params:
        rank=config["fixed_pca"]["rank"],
    resources:
        mem="128G",
        runtime="1h",
    threads: 24
    conda:
        "../../conda/conda.yaml"
    script:
        "../../scripts/scran_fixedpca.R"

rule scran_umap:
    input:
        sce="results/filter_mitochondria/_pca.rds",
    output:
        sce="results/filter_mitochondria/_umap.rds",
    params:
        n_pcs=config["umap"]["n_pcs"],
    resources:
        mem="20G",
        runtime="1h",
    threads: 32
    conda:
        "../../conda/conda.yaml"
    script:
        "../../scripts/scater_umap.R"

rule enrichgo_hvgs:
    input:
        hvgs="results/model_gene_var/variable_genes.txt",
        bg="results/filter_mitochondria/_logcounts_rownames.txt"
    output:
        rds="results/enrichgo/hvgs.rds",
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="8G",
        runtime="10m",
    script:
        "../../scripts/enrichgo_genes.R"
