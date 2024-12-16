message(Sys.time())

suppressPackageStartupMessages({library(BiocParallel)})
suppressPackageStartupMessages({library(DropletUtils)})
suppressPackageStartupMessages({library(fishpond)})
suppressPackageStartupMessages({library(SummarizedExperiment)})
suppressPackageStartupMessages({library(tidyverse)})

message("Job configuration")
message("- threads: ", snakemake@threads)
message("- lower: ", snakemake@params[["lower"]])
message("- niters: ", snakemake@params[["niters"]])
stopifnot(is.numeric(snakemake@threads))
stopifnot(is.numeric(snakemake@params[["lower"]]))
stopifnot(is.numeric(snakemake@params[["niters"]]))

sample_fry_dir <- file.path(snakemake@input[["simpleaf"]], "af_quant")
message("Input directory: ", sample_fry_dir)
stopifnot(dir.exists(sample_fry_dir))

message("Loading sample ... ")
sce <- loadFry(fryDir = sample_fry_dir, outputFormat = "S+A", quiet = TRUE)
message("Done.")

message("Loading lower threshold from file ... ")
ignore <- scan(snakemake@input[["ignore"]], "integer")
message("Done.")

message("Lower threshold: ", lower)

message("Running emptyDrops ...")
set.seed(100)
emptydrops_out <- emptyDrops(
    m = assay(sce, "counts"),
    lower = lower,
    niters = snakemake@params[["niters"]],
    ignore = ignore
    BPPARAM = MulticoreParam(workers = as.integer(snakemake@threads))
)
message("Done.")

message("Saving to RDS file ...")
saveRDS(emptydrops_out, snakemake@output[["rds"]])
message("Done.")

message(Sys.time())
