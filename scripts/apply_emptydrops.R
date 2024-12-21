message(Sys.time())

suppressPackageStartupMessages({library(SummarizedExperiment)})

message("Job configuration")
message("- fdr: ", snakemake@params[["fdr"]])
stopifnot(is.numeric(snakemake@params[["fdr"]]))

message("Loading sample ... ")
sce <- readRDS(snakemake@input[["sce"]])
message("Done.")

message("Load emptyDrops results ...")
emptydrops <- readRDS(snakemake@input[["emptydrops"]])
message("Done.")

message("Apply emptyDrops filter ...")
keep <- which(emptydrops$FDR < snakemake@params[["fdr"]])
sce <- sce[, keep]
message("Done.")

message("Saving to RDS file ...")
saveRDS(sce, snakemake@output[["rds"]])
message("Done.")

message(Sys.time())
