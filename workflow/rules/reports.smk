rule simpleaf_all_barcodes_report:
    input:
        rds="results/sce/all.rds",
    output:
        "results/reports/alevin.html",
    params:
        umi_cutoff_low=config["barcode_filters"]["min_umis"],
        genes_cutoff_low=config["barcode_filters"]["min_genes"],
        umi_cutoff_final=config["barcode_filters"]["final"]["min_umis"],
        genes_cutoff_final=config["barcode_filters"]["final"]["min_genes"],
    conda:
        "../../conda/bioconductor_3_20.yaml"
    threads: 2
    resources:
        mem="64G",
        runtime="30m",
    script:
        "../../notebooks/simpleaf_barcodes_all_report.Rmd"

rule simpleaf_sample_report:
    input:
        simpleaf="results/alevin/{sample}",
    output:
        "results/reports/alevin/{sample}.html",
    params:
        umi_cutoff=config["barcode_filters"]["final"]["min_umis"],
    conda:
        "../../conda/bioconductor_3_20.yaml"
    threads: 2
    resources:
        mem="16G",
        runtime="30m",
    script:
        "../../notebooks/simpleaf_sample_report.Rmd"

rule emptydrop_report_all:
    input:
        rds="results/emptydrops/results.rds",
    output:
        "results/reports/emptydrops.html",
    conda:
        "../../conda/bioc_dropletutils.yaml"
    threads: 2
    resources:
        mem="32G",
        runtime="30m",
    script:
        "../../notebooks/emptydrops_report.Rmd"

rule emptydrop_report_sample:
    input:
        rds="results/emptydrops/{sample}.rds",
    output:
        "results/reports/emptydrops/{sample}.html",
    conda:
        "../../conda/bioc_dropletutils.yaml"
    threads: 2
    resources:
        mem="16G",
        runtime="10m",
    script:
        "../../notebooks/emptydrops_report.Rmd"

rule scran_umap_report:
    input:
        rds="results/sce/umap.rds",
    output:
        "results/umap-reports/without-integration.html",
    conda:
        "../../conda/bioconductor_3_20.yaml"
    threads: 2
    resources:
        mem="64G",
        runtime="30m",
    script:
        "../../notebooks/osca_umap_report.Rmd"

rule scran_umap_report_final:
    input:
        rds="results/sce/umap-final.rds",
    output:
        "results/umap-reports/without-integration-final.html",
    conda:
        "../../conda/bioconductor_3_20.yaml"
    threads: 2
    resources:
        mem="64G",
        runtime="30m",
    script:
        "../../notebooks/osca_umap_report.Rmd"

rule enrichgo_hvgs_report:
    input:
        rds="results/enrichgo/hvgs.rds",
    output:
        "results/enrichgo-reports/hvgs.html",
    conda:
        "../../conda/bioconductor_3_20-v2.yaml"
    threads: 2
    resources:
        mem="8G",
        runtime="10m",
    script:
        "../../notebooks/clusterprofiler_enrichgo.Rmd"

rule enrichgo_hvgs_report_final:
    input:
        rds="results/enrichgo/hvgs-final.rds",
    output:
        "results/enrichgo-reports/hvgs-final.html",
    conda:
        "../../conda/bioconductor_3_20-v2.yaml"
    threads: 2
    resources:
        mem="8G",
        runtime="10m",
    script:
        "../../notebooks/clusterprofiler_enrichgo.Rmd"
