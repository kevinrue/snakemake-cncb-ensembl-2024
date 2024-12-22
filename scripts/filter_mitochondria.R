message(Sys.time())

suppressPackageStartupMessages({library(SummarizedExperiment)})
suppressPackageStartupMessages({library(tidyverse)})

message("Job configuration")
message("- pct_max: ", snakemake@params[["pct_max"]])

message("Loading mitochondrial gene ids ... ")
mito_gene_ids <- read_tsv("config/mitochdondrial_genes.tsv", show_col_types = FALSE)[["gene_id"]]
message("Done.")

message("Loading sample ... ")
sce <- readRDS(snakemake@input[["sce"]])
message("Done.")

message("Compute mitochondrial content ...")
mt_pct <- colSums(assay(sce, "counts")[mito_gene_ids, ]) / colSums(assay(sce, "counts"))
message("Done.")

message("Apply emptyDrops filter ...")
keep <- which(mt_pct <= snakemake@params[["pct_max"]])
sce <- sce[, keep]
message("Done.")

message("Saving to RDS file ...")
saveRDS(sce, snakemake@output[["sce"]])
message("Done.")

message(Sys.time())
