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

barcoderank_file <- snakemake@input[["barcoderank"]]
message("barcodeRanks file: ", barcoderank_file)
stopifnot(file.exists(barcoderank_file))

ignore_file <- snakemake@input[["ignore"]]
message("Ignore file: ", ignore_file)
stopifnot(file.exists(ignore_file))

message("Loading ignore UMI threshold for expected cell number ... ")
ignore <- scan(ignore_file, what = integer(), quiet = TRUE)
message("Done.")

message("ignore: ", ignore)

message("Loading barcodeRanks results ... ")
barcoderank_results <- readRDS(barcoderank_file)
retain <- metadata(barcoderank_results)[["knee"]]
message("Done.")

message("retain: ", retain)

message("Loading sample ... ")
sce <- loadFry(fryDir = sample_fry_dir, outputFormat = "S+A", quiet = TRUE)
message("Done.")

message("Running emptyDrops ...")
set.seed(100)
emptydrops_out <- emptyDrops(
    m = assay(sce, "counts"),
    lower = snakemake@params[["lower"]],
    retain = retain,
    niters = snakemake@params[["niters"]],
    ignore = ignore,
    BPPARAM = MulticoreParam(workers = as.integer(snakemake@threads))
)
message("Done.")

message("Adding custom metadata ...")
metadata(emptydrops_out)[["ignore"]] <- ignore
message("Done.")

message("Saving to RDS file ...")
saveRDS(emptydrops_out, snakemake@output[["rds"]])
message("Done.")

message(Sys.time())
