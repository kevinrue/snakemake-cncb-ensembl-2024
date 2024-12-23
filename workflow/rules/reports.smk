rule simpleaf_sample_report:
    input:
        sce="results/fishpond/{sample}.rds",
    output:
        "reports/simpleaf/{sample}.html",
    params:
        expect_cells=lambda wildcards, input: SAMPLES['expect_cells'][wildcards.sample],
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="8G",
        runtime="5m",
    script:
        "../../notebooks/simpleaf_sample_report.Rmd"

rule simpleaf_all_report:
    input:
        rds="results/fishpond/_all.rds",
    output:
        "reports/simpleaf.html",
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="64G",
        runtime="30m",
    script:
        "../../notebooks/simpleaf_all_report.Rmd"

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

rule emptydrop_report_sample:
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

rule mitochondrial_report_sample:
    input:
        sce="results/filter_mitochondria/{sample}.rds",
    output:
        "reports/filter_mitochondria/{sample}.html",
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="16G",
        runtime="10m",
    script:
        "../../notebooks/mitochondrial_report.Rmd"

rule scran_umap_report:
    input:
        sce="results/filter_mitochondria/_umap.rds",
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

rule enrichgo_hvgs_report:
    input:
        rds="results/enrichgo/hvgs.rds",
    output:
        "reports/enrichgo/hvgs.html",
    conda:
        "../../conda/conda.yaml"
    threads: 2
    resources:
        mem="8G",
        runtime="10m",
    script:
        "../../notebooks/clusterprofiler_enrichgo.Rmd"
