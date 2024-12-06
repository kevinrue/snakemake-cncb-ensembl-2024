message(Sys.time())

suppressPackageStartupMessages({library(BiocParallel)})
suppressPackageStartupMessages({library(SingleCellExperiment)})
suppressPackageStartupMessages({library(scuttle)})

message("Job configuration")
message("- threads: ", snakemake@threads)

message("Importing from RDS file ...")
sce <- readRDS(snakemake@input[["rds"]])
message("Done.")

message("Log-normalise ...")
sce <- logNormCounts(sce, BPPARAM = MulticoreParam(workers = snakemake@threads))
message("Done.")

message("Remove assay 'counts' ...")
assay(sce, "counts") <- NULL
message("Done.")

message("Saving to RDS file ...")
saveRDS(sce, snakemake@output[["rds"]])
message("Done.")

message(Sys.time())
