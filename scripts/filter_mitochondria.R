message(Sys.time())

suppressPackageStartupMessages({library(SingleCellExperiment)})
suppressPackageStartupMessages({library(tidyverse)})

message("Job configuration")
message("- pct_max: ", snakemake@params[["pct_max"]])

message("Loading mitochondrial gene ids ... ")
mito_gene_ids <- read_tsv("config/mitochdondrial_genes.tsv", show_col_types = FALSE)[["gene_id"]]
message("Done.")

message("Loading sample ... ")
sce <- readRDS(snakemake@input[["sce"]])
message("Done.")

message("Computing mitochondrial content ...")
mt_pct <- colSums(assay(sce, "counts")[mito_gene_ids, ]) / colSums(assay(sce, "counts"))
message("Done.")

message("Applying mitochondrial content filter ...")
keep <- mt_pct <= snakemake@params[["pct_max"]]
message("* Barcodes filtered: ", format(sum(!keep), big.mark = ","))
sce <- sce[, which(keep)]
message("Done.")

message("Saving to RDS file ...")
saveRDS(sce, snakemake@output[["sce"]])
message("Done.")

message(Sys.time())
