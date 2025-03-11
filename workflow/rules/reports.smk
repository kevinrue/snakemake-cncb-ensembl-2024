rule packages_report:
    input:
        conda="conda/conda.yaml",
    output:
        "reports/packages.html",
    conda:
        "../../conda/conda.yaml"
    threads: 1
    resources:
        mem="2G",
        runtime="5m",
    script:
        "../../notebooks/packages_report.Rmd"

rule fishpond_sample_report:
    input:
        sce="results/fishpond/{sample}.rds",
    output:
        "reports/fishpond/{sample}.html",
    params:
        expect_cells=lambda wildcards, input: SAMPLES['expect_cells'][wildcards.sample],
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="8G",
        runtime="5m",
    script:
        "../../notebooks/fishpond_sample_report.Rmd"

rule fishpond_all_report:
    input:
        rds="results/fishpond/_all.rds",
    output:
        "reports/fishpond.html",
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="64G",
        runtime="30m",
    script:
        "../../notebooks/fishpond_all_report.Rmd"

rule barcoderanks_report:
    input:
        rds="results/barcodeRanks/{sample}.rds",
    output:
        "reports/barcodeRanks/{sample}.html",
    params:
        expect_cells=lambda wildcards, input: SAMPLES['expect_cells'][wildcards.sample],
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="16G",
        runtime="10m",
    script:
        "../../notebooks/barcoderanks_report.Rmd"

rule emptydrops_sample_report:
    input:
        rds="results/emptyDrops/result/{sample}.rds",
    output:
        "reports/emptyDrops/{sample}.html",
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="16G",
        runtime="10m",
    script:
        "../../notebooks/emptydrops_report.Rmd"

rule emptydrops_all_report:
    input:
        expand("results/emptyDrops/result/{sample}.rds", sample=SAMPLES['sample_name'].unique()),
    output:
        "reports/emptyDrops.html",
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="16G",
        runtime="10m",
    script:
        "../../notebooks/emptydrops_all_report.Rmd"

rule after_emptydrops_sample_report:
    input:
        sce="results/emptyDrops/sce/{sample}.rds",
        mt="config/mitochondrial_genes.tsv",
        gtf="resources/genome/genome.gtf.gz",
    output:
        "reports/after_emptyDrops/{sample}.html",
    params:
        n_pcs_umap=lambda wildcards, input: SAMPLES['npcs'][wildcards.sample],
    conda:
        "../../conda/conda.yaml"
    threads: 12
    resources:
        mem="32G",
        runtime="30m",
    script:
        "../../notebooks/sample_report.Rmd"

rule before_scdblfinder_sample_report:
    input:
        sce="results/before_scdblfinder/{sample}.rds",
    output:
        "reports/before_scdblfinder/{sample}.html",
    conda:
        "../../conda/conda-2.yaml"
    threads: 2
    resources:
        mem="16G",
        runtime="10m",
    script:
        "../../notebooks/parameter_scan_sample_report.Rmd"

rule scdblfinder_sample_report:
    input:
        scdblfinder="results/scdblfinder/result/{sample}.rds",
        sce="results/before_scdblfinder/{sample}.rds",
    output:
        "reports/scdblfinder/{sample}.html",
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="16G",
        runtime="10m",
    script:
        "../../notebooks/scdblfinder_report.Rmd"

rule enrichgo_hvgs_report:
    input:
        rds="results/enrichgo/hvgs.rds",
    output:
        "reports/hvgs.html",
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="8G",
        runtime="10m",
    script:
        "../../notebooks/clusterprofiler_enrichgo.Rmd"

rule scran_umap_report:
    input:
        rds="results/filter_mitochondria/_umap.rds",
    output:
        "reports/umap.html",
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="8G",
        runtime="5m",
    script:
        "../../notebooks/osca_umap_report.Rmd"

rule fastmnn_report:
    input:
        rds="results/fastmnn/sce.rds",
    output:
        "reports/fastmnn.html",
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="8G",
        runtime="5m",
    script:
        "../../notebooks/fastmnn_report.Rmd"

rule scran_umap_after_integration_report:
    input:
        rds="results/fastmnn/umap.rds",
    output:
        "reports/umap_after_integration.html",
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="8G",
        runtime="5m",
    script:
        "../../notebooks/osca_umap_after_integration_report.Rmd"

rule clustering_report:
    input:
        umap="results/fastmnn/umap.rds",
        clusters="results/fastmnn/clusters.rds",
    output:
        "reports/clustering_report.html",
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="16G",
        runtime="20m",
    script:
        "../../notebooks/clustering_report.Rmd"

rule markers_report:
    input:
        markers="results/fastmnn/markers.rds",
    output:
        "reports/markers_report.html",
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="16G",
        runtime="20m",
    script:
        "../../notebooks/markers_report.Rmd"

rule custom_markers_report:
    input:
        logcounts="results/filter_mitochondria/_logcounts.rds",
        umap="results/fastmnn/umap.rds",
    output:
        "reports/custom_markers_report.html",
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="32G",
        runtime="20m",
    script:
        "../../notebooks/custom_markers_report.Rmd"


