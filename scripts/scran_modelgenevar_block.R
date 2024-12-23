message(Sys.time())

suppressPackageStartupMessages({library(BiocParallel)})
suppressPackageStartupMessages({library(SingleCellExperiment)})
suppressPackageStartupMessages({library(scran)})
suppressPackageStartupMessages({library(scuttle)})
suppressPackageStartupMessages({library(tidyverse)})

message("Job configuration")
message("- threads: ", snakemake@threads)
message("- block: ", snakemake@params[["block"]])
message("- HVGs proportion: ", snakemake@params[["hvgs_prop"]])

message("Importing SCE from RDS file ...")
sce <- readRDS(snakemake@input[["sce"]])
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Model gene variance ...")
dec <- modelGeneVar(
    x = sce,
    block = colData(sce)[[snakemake@params[["block"]]]],
    BPPARAM = MulticoreParam(workers = snakemake@threads)
)
message("Done.")

message(Sys.time())

message("Saving modelGeneVar result to RDS ...")
saveRDS(dec, snakemake@output[["rds"]])
message("Done.")

message("Selecting highly variable genes ...")
chosen <- getTopHVGs(dec, prop = snakemake@params[["hvgs_prop"]])
message("Done.")

message("Writing highly variable genes to TXT ...")
write(chosen, snakemake@output[["hvgs"]])
message("Done.")

message(Sys.time())
