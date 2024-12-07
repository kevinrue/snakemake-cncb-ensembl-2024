message(Sys.time())

suppressPackageStartupMessages({library(BiocParallel)})
suppressPackageStartupMessages({library(BiocSingular)})
suppressPackageStartupMessages({library(SingleCellExperiment)})
suppressPackageStartupMessages({library(scran)})
suppressPackageStartupMessages({library(tidyverse)})

message("Job configuration")
message("- threads: ", snakemake@threads)
message("- rank: ", snakemake@params[["rank"]])

message("Importing SCE from RDS file ...")
sce <- readRDS(snakemake@input[["sce"]])
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Importing variable genes form TXT file ...")
hvgs <- scan(snakemake@input[["hvgs"]], what = character())
message("Done.")

message("Running PCA ...")
set.seed(1000)
sce <- fixedPCA(
  sce,
  subset.row = hvgs,
  rank = snakemake@params[["rank"]],
  BSPARAM = RandomParam(),
  BPPARAM = MulticoreParam(workers = snakemake@threads)
)
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Plotting variance explained ...")
pdf(snakemake@output[["var_explained"]], width = 10, height = 5)
percent.var <- attr(reducedDim(sce), "percentVar")
plot(percent.var, log="y", xlab="PC", ylab="Variance explained (%)")
dev.off()
message("Done.")

message("Removing assays ...")
assays(sce) <- list()
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Saving SCE to RDS file ...")
saveRDS(sce, snakemake@output[["sce"]])
message("Done.")

message(Sys.time())
