message(Sys.time())

suppressPackageStartupMessages({library(BiocParallel)})
suppressPackageStartupMessages({library(SingleCellExperiment)})
suppressPackageStartupMessages({library(DropletUtils)})
suppressPackageStartupMessages({library(tidyverse)})

message("Job configuration")
message("- threads: ", snakemake@threads)
message("- lower: ", snakemake@params[["lower"]])
message("- niters: ", snakemake@params[["niters"]])
stopifnot(is.numeric(snakemake@threads))
stopifnot(is.numeric(snakemake@params[["lower"]]))
stopifnot(is.numeric(snakemake@params[["niters"]]))

message("Importing from RDS file ...")
sce <- readRDS(snakemake@input[["rds"]])
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Running emptyDrops ...")
set.seed(100)
emptydrops_out <- emptyDrops(
    m = assay(sce, "counts"),
    lower = snakemake@params[["lower"]],
    niters = snakemake@params[["niters"]],
    BPPARAM = MulticoreParam(workers = as.integer(snakemake@threads))
)
message("Done.")

message("Table object size: ", format(object.size(emptydrops_out), unit = "GB"))

message("Saving to RDS file ...")
write_tsv(
    emptydrops_out %>% as.data.frame() %>% as_tibble(),
    snakemake@output[["tsv"]]
)
message("Done.")

message(Sys.time())
