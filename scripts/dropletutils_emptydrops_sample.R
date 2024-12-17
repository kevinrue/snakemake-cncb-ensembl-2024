message(Sys.time())

suppressPackageStartupMessages({library(BiocParallel)})
suppressPackageStartupMessages({library(DropletUtils)})
suppressPackageStartupMessages({library(fishpond)})
suppressPackageStartupMessages({library(SummarizedExperiment)})
suppressPackageStartupMessages({library(tidyverse)})

message("Job configuration")
message("- threads: ", snakemake@threads)
message("- expect_cells: ", snakemake@params[["expect_cells"]])
message("- lower: ", snakemake@params[["lower"]])
message("- niters: ", snakemake@params[["niters"]])
stopifnot(is.numeric(snakemake@threads))
stopifnot(is.numeric(snakemake@params[["expect_cells"]]))
stopifnot(is.numeric(snakemake@params[["lower"]]))
stopifnot(is.numeric(snakemake@params[["niters"]]))

sample_fry_dir <- file.path(snakemake@input[["simpleaf"]], "af_quant")
message("Input directory: ", sample_fry_dir)
stopifnot(dir.exists(sample_fry_dir))

message("Loading sample ... ")
sce <- loadFry(fryDir = sample_fry_dir, outputFormat = "S+A", quiet = TRUE)
message("Done.")

message("Identifying lower UMI count for expected cell number  ...")
umi_sum <- colSums(assay(sce, "counts"))
ignore <- sort(umi_sum, decreasing = TRUE)[snakemake@params[["expect_cells"]]]
message("Done.")

message("Value: ", ignore)

message("Running emptyDrops ...")
set.seed(100)
emptydrops_out <- emptyDrops(
    m = assay(sce, "counts"),
    lower = snakemake@params[["lower"]],
    niters = snakemake@params[["niters"]],
    ignore = ignore,
    BPPARAM = MulticoreParam(workers = as.integer(snakemake@threads))
)
message("Done.")

message("Saving to RDS file ...")
saveRDS(emptydrops_out, snakemake@output[["rds"]])
message("Done.")

message(Sys.time())
