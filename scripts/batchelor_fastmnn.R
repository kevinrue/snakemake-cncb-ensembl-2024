message(Sys.time())

suppressPackageStartupMessages({library(batchelor)})
suppressPackageStartupMessages({library(BiocNeighbors)})
suppressPackageStartupMessages({library(BiocSingular)})
suppressPackageStartupMessages({library(SummarizedExperiment)})

message("Job configuration")
message("- threads: ", snakemake@threads)
message("- batch: ", snakemake@params[["batch"]])
message("- k: ", snakemake@params[["k"]])
message("- d: ", snakemake@params[["d"]])

message("Importing variable genes from TXT file ...")
hvgs <- scan(snakemake@input[["hvgs"]], what = character())
message("Done.")

message("Loading sample ... ")
sce <- readRDS(snakemake@input[["sce"]])
message("Done.")

message("Apply fastMNN ...")
sce <- fastMNN(
    sce,
    batch = colData(sce)[[snakemake@params[["batch"]]]],
    k = snakemake@params[["k"]],
    d = snakemake@params[["d"]],
    auto.merge = TRUE,
    subset.row = hvgs,
    correct.all = TRUE,
    assay.type = "logcounts",
    BSPARAM = IrlbaParam(),
    BNPARAM = KmknnParam(),
    BPPARAM = MulticoreParam(workers = snakemake@threads)
)
message("Done.")

message("Saving to RDS file ...")
saveRDS(sce, snakemake@output[["rds"]])
message("Done.")

message(Sys.time())
