rule simpleaf_all_report:
    input:
        rds="results/sce/counts.rds",
    output:
        "reports/simpleaf.html",
    params:
        umi_cutoff=config["filters"]["barcodes"]["min_umis"],
        genes_cutoff=config["filters"]["barcodes"]["min_genes"],
        expect_cells=config["filters"]["barcodes"]["expected"], # not ideal, same value for all samples!
    conda:
        "../../conda/bioconductor_3_20.yaml"
    threads: 2
    resources:
        mem="64G",
        runtime="30m",
    script:
        "../../notebooks/simpleaf_all_report.Rmd"

rule simpleaf_sample_report:
    input:
        simpleaf="results/simpleaf/quant/{sample}",
    output:
        "reports/simpleaf/{sample}.html",
    params:
        umi_cutoff=config["filters"]["barcodes"]["min_umis"],
    conda:
        "../../conda/bioconductor_3_20.yaml"
    threads: 2
    resources:
        mem="16G",
        runtime="30m",
    script:
        "../../notebooks/simpleaf_sample_report.Rmd"

rule barcoderanks_report:
    input:
        rds="results/barcodeRanks/{sample}.rds",
    output:
        "reports/barcodeRanks/{sample}.html",
    conda:
        "../../conda/bioc_dropletutils.yaml"
    threads: 2
    resources:
        mem="16G",
        runtime="10m",
    script:
        "../../notebooks/barcoderanks_report.Rmd"

rule emptydrop_report_all:
    input:
        rds="results/emptyDrops/results.rds",
    output:
        "reports/emptyDrops.html",
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
        rds="results/emptyDrops/{sample}.rds",
    output:
        "reports/emptyDrops/{sample}.html",
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
        "reports/umap.html",
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
        "reports/enrichgo/hvgs.html",
    conda:
        "../../conda/bioconductor_3_20-v2.yaml"
    threads: 2
    resources:
        mem="8G",
        runtime="10m",
    script:
        "../../notebooks/clusterprofiler_enrichgo.Rmd"
