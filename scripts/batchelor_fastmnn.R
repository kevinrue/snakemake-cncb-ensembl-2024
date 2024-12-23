message(Sys.time())

suppressPackageStartupMessages({library(batchelor)})
suppressPackageStartupMessages({library(BiocNeighbors)})
suppressPackageStartupMessages({library(BiocParallel)})
suppressPackageStartupMessages({library(BiocSingular)})
suppressPackageStartupMessages({library(SummarizedExperiment)})
suppressPackageStartupMessages({library(tidyverse)})

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
message("* Number of cells: ", ncol(sce))
message("* Number of feature: ", nrow(sce))
message("Done.")

timepoint_levels <- c("m048hrs", "m024hrs", "p000hrs", "p024hrs", "p048hrs", "p072hrs", "p096hrs", "p120hrs")
replicate_levels <- c("1", "2")
colData(sce) <- str_match(string = colData(sce)[["sample"]], pattern = "WPP(?<timepoint>[mp][[:digit:]]{3}hrs)_rep(?<replicate>[[:digit:]]{1})")[, -1] %>%
  as_tibble() %>%
  mutate(
    timepoint = factor(timepoint, timepoint_levels),
    replicate = factor(replicate, replicate_levels)
  ) %>%
  as("DataFrame")

message("Apply fastMNN ...")
message("* Number of batches: ", length(unique(colData(sce)[[snakemake@params[["batch"]]]])))
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
saveRDS(sce, snakemake@output[["sce"]])
message("Done.")

message(Sys.time())
