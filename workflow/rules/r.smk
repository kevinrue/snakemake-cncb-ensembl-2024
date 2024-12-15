rule simpleaf_lower_umi_per_sample:
    input:
        alevin="results/simpleaf/quant/{sample}",
    output:
        txt="results/simpleaf/lower/{sample}.txt",
    params:
        expect_cells=lambda wildcards, input: SAMPLES['expect_cells'][wildcards.sample],
    threads: 2
    resources:
        mem="32G",
        runtime="10m",
    conda:
        "../../conda/bioconductor_3_20.yaml"
    script:
        "../../scripts/simpleaf_find_lower.R"

rule alevin_all_rds:
    input:
        expand("results/simpleaf/quant/{sample}", sample=SAMPLES['sample_name'].unique()),
    output:
        rds="results/sce/counts.rds",
    threads: 16
    resources:
        mem="128G",
        runtime="1h",
    conda:
        "../../conda/bioconductor_3_20.yaml"
    script:
        "../../scripts/simpleaf_merge.R"

rule dropletutils_emptydrops_per_sample:
    input:
        alevin="results/simpleaf/quant/{sample}",
    output:
        rds="results/emptydrops/{sample}.rds",
    params:
        lower=config["emptydrops"]["lower"],
        niters=config["emptydrops"]["niters"],
    conda:
        "../../conda/bioc_dropletutils.yaml"
    threads: 12
    resources:
        mem="64G",
        runtime="30m",
    script:
        "../../scripts/dropletutils_emptydrops_sample.R"

rule dropletutils_emptydrops_all:
    input:
        rds="results/sce/counts.rds",
    output:
        rds="results/emptyDrops/results.rds",
    params:
        lower=config["emptydrops"]["lower"],
        niters=config["emptydrops"]["niters"],
    conda:
        "../../conda/bioc_dropletutils.yaml"
    threads: 24
    resources:
        mem="256G",
        runtime="1h",
    script:
        "../../scripts/dropletutils_emptydrops.R"

rule dropletutils_barcode_ranks:
    input:
        alevin="results/simpleaf/quant/{sample}",
    output:
        rds="results/barcodeRanks/{sample}.rds",
    params:
        lower=config["emptydrops"]["lower"],
    conda:
        "../../conda/bioc_dropletutils.yaml"
    threads: 12
    resources:
        mem="64G",
        runtime="30m",
    script:
        "../../scripts/dropletutils_barcoderanks.R"

rule alevin_all_hdf5:
    input:
        rds="results/sce/counts.rds",
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
        rds="results/sce/counts.rds",
    output:
        rds="results/sce/lognorm.rds",
    params:
        min_umis=config["filters"]["barcodes"]["min_umis"],
        min_genes=config["filters"]["barcodes"]["min_genes"],        
    resources:
        mem="128G",
        runtime="1h",
    threads: 32
    conda:
        "../../conda/bioconductor_3_20.yaml"
    script:
        "../../scripts/scuttle_lognorm.R"

rule scuttle_lognorm_final:
    input:
        rds="results/sce/counts.rds",
    output:
        rds="results/sce/lognorm-final.rds",
    params:
        min_umis=config["filters"]["barcodes"]["min_umis"],
        min_genes=config["filters"]["barcodes"]["min_genes"],        
    resources:
        mem="128G",
        runtime="1h",
    threads: 32
    conda:
        "../../conda/bioconductor_3_20.yaml"
    script:
        "../../scripts/scuttle_lognorm.R"

rule background_gene_ids:
    input:
        rds="results/sce/lognorm.rds",
    output:
        txt="results/sce/lognorm_rownames.txt"
    conda:
        "../../conda/bioconductor_3_20.yaml"
    threads: 2
    resources:
        mem="64G",
        runtime="30m",
    script:
        "../../scripts/sce_rownames.R"
        
rule background_gene_ids_final:
    input:
        rds="results/sce/lognorm-final.rds",
    output:
        txt="results/sce/lognorm_rownames-final.txt"
    conda:
        "../../conda/bioconductor_3_20.yaml"
    threads: 2
    resources:
        mem="64G",
        runtime="30m",
    script:
        "../../scripts/sce_rownames.R"

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

rule scran_hvgs_final:
    input:
        rds="results/sce/lognorm-final.rds",
    output:
        tsv="results/model_gene_var/decomposed_variance-final.tsv",
        fit="results/model_gene_var/fit-final.pdf",
        hvgs="results/model_gene_var/variable_genes-final.txt",
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

rule scran_fixed_pca_final:
    input:
        sce="results/sce/lognorm-final.rds",
        hvgs="results/model_gene_var/variable_genes-final.txt",
    output:
        var_explained="results/fixed_pca/var_explained-final.pdf",
        sce="results/sce/pca-final.rds",
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

rule scran_umap_final:
    input:
        sce="results/sce/pca-final.rds",
    output:
        sce="results/sce/umap-final.rds",
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

rule enrichgo_hvgs:
    input:
        hvgs="results/model_gene_var/variable_genes.txt",
        bg="results/sce/lognorm_rownames.txt"
    output:
        rds="results/enrichgo/hvgs.rds",
    conda:
        "../../conda/bioconductor_3_20-v2.yaml"
    threads: 2
    resources:
        mem="8G",
        runtime="10m",
    script:
        "../../scripts/enrichgo_genes.R"

rule enrichgo_hvgs_final:
    input:
        hvgs="results/model_gene_var/variable_genes-final.txt",
        bg="results/sce/lognorm_rownames-final.txt"
    output:
        rds="results/enrichgo/hvgs-final.rds",
    conda:
        "../../conda/bioconductor_3_20-v2.yaml"
    threads: 2
    resources:
        mem="8G",
        runtime="10m",
    script:
        "../../scripts/enrichgo_genes.R"