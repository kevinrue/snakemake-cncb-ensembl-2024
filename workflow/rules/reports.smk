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

rule simpleaf_all_barcodes_report:
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
