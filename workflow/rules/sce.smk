rule sce_rownames:
    input:
        rds="results/sce/all.rds",
    output:
        txt="results/sce/all_rownames.txt"
    conda:
        "../../conda/bioconductor_3_20.yaml"
    threads: 2
    resources:
        mem="32G",
        runtime="10m",
    script:
        "../../scripts/sce_rownames.R"

rule enrichgo_hvgs:
    input:
        hvgs="results/model_gene_var/variable_genes.txt",
        bg="results/sce/all_rownames.txt",
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
