rule simpleaf_sample_report:
    input:
        simpleaf="results/alevin/{sample}",
    output:
        "results/alevin-reports/{sample}.html",
    conda:
        "../../conda/bioconductor_3_20.yaml"
    threads: 2
    resources:
        mem="16G",
        runtime="30m",
    script:
        "../../notebooks/simpleaf_sample_report.Rmd"

rule simpleaf_all_barcodes_report:
    input:
        rds="results/sce/all.rds",
    output:
        "results/alevin-reports/all.html",
    conda:
        "../../conda/bioconductor_3_20.yaml"
    threads: 2
    resources:
        mem="64G",
        runtime="30m",
    script:
        "../../notebooks/simpleaf_barcodes_all_report.Rmd"

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

rule enrichgo_hvgs_report:
    input:
        rds="results/enrichgo/hvgs.rds",
    output:
        "results/enrichgo-reports/hvgs.html",
    conda:
        "../../conda/bioconductor_3_20.yaml"
    threads: 2
    resources:
        mem="8G",
        runtime="10m",
    script:
        "../../scripts/clusterprofiler_enrichgo.Rmd"
