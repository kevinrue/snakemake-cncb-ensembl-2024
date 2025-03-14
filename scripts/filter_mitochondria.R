message(Sys.time())

suppressPackageStartupMessages({library(SingleCellExperiment)})
suppressPackageStartupMessages({library(tidyverse)})

sce_rds <- snakemake@input[["sce"]]
mt_tsv <- snakemake@input[["mt"]]
pct_max <- snakemake@params[["pct_max"]]

message("Job configuration")
message("- sce_rds: ", sce_rds)
message("- mt_tsv: ", mt_tsv)
message("- pct_max: ", pct_max)

message("Loading mitochondrial gene ids ... ")
mito_gene_ids <- read_tsv(mt_tsv, show_col_types = FALSE)[["gene_id"]]
message("Done.")

message("Loading sample ... ")
sce <- readRDS(sce_rds)
message("Done.")

message("Computing mitochondrial content ...")
mt_pct <- colSums(assay(sce, "counts")[mito_gene_ids, ]) / colSums(assay(sce, "counts"))
message("Done.")

message("Applying mitochondrial content filter ...")
keep <- mt_pct <= pct_max
message("* Barcodes filtered: ", format(sum(!keep), big.mark = ","))
sce <- sce[, which(keep)]
message("Done.")

message("Saving to RDS file ...")
saveRDS(sce, snakemake@output[["sce"]])
message("Done.")

message(Sys.time())
