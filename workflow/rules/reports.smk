rule simpleaf_sample_report:
    input:
        simpleaf="results/alevin/{sample}",
    output:
        "results/alevin-reports/{sample}.html",
    # container: "docker://bioconductor/bioconductor_docker:RELEASE_3_20"
    conda:
        "../../conda/bioconductor_3_20.yaml"
    threads: 2
    resources:
        mem="16G",
        runtime="30m",
    script:
        "../../notebooks/simpleaf_sample_report.Rmd"

rule simpleaf_merged_umap:
    input:
        simpleaf="results/alevin/{sample}",
    output:
        "results/alevin-reports/{sample}.html",
    # container: "docker://bioconductor/bioconductor_docker:RELEASE_3_20"
    conda:
        "../../conda/bioconductor_3_20.yaml"
    threads: 2
    resources:
        mem="16G",
        runtime="30m",
    script:
        "../../notebooks/simpleaf_sample_report.Rmd"
