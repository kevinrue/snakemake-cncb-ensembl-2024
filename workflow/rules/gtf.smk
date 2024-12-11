rule gtf_find_duplicates:
    input:
        gtf="resources/genome/genome.gtf.gz",
    output:
        tsv="resources/gtf/duplicated_gene_models.tsv",
    threads: 2
    resources:
        mem="8G",
        runtime="20m",
    conda:
        "../../conda/conda.yaml"
    script:
        "../../scripts/gtf_find_duplicates.R"
