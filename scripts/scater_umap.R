message(Sys.time())

suppressPackageStartupMessages({library(BiocParallel)})
suppressPackageStartupMessages({library(BiocNeighbors)})
suppressPackageStartupMessages({library(SingleCellExperiment)})
suppressPackageStartupMessages({library(scater)})
suppressPackageStartupMessages({library(tidyverse)})

message("Job configuration")
message("- threads: ", snakemake@threads)
message("- n_pcs: ", snakemake@params[["n_pcs"]])

message("Importing SCE from RDS file ...")
sce <- readRDS(snakemake@input[["sce"]])
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Running UMAP ...")
set.seed(1000)
sce <- runUMAP(
  sce,
  dimred = "PCA",
  pca = snakemake@params[["n_pcs"]],
  BNPARAM = KmknnParam(),
  BPPARAM = MulticoreParam(workers = snakemake@threads)
)
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Removing PCA ...")
reducedDim(sce, "PCA") <- NULL
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Saving SCE to RDS file ...")
saveRDS(sce, snakemake@output[["sce"]])
message("Done.")

message(Sys.time())
