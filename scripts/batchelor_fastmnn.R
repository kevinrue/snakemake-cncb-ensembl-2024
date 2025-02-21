message(Sys.time())

suppressPackageStartupMessages(library(batchelor))
suppressPackageStartupMessages(library(BiocNeighbors))
suppressPackageStartupMessages(library(BiocParallel))
suppressPackageStartupMessages(library(BiocSingular))
suppressPackageStartupMessages(library(SummarizedExperiment))
suppressPackageStartupMessages(library(tidyverse))

snakemake_params_batch <- snakemake@params[["batch"]]
snakemake_params_d <- snakemake@params[["d"]]
snakemake_params_k <- snakemake@params[["k"]]

message("Job configuration")
message("- threads: ", snakemake@threads)
message("- batch: ", snakemake_params_batch)
message("- k: ", snakemake_params_k)
message("- d: ", snakemake_params_d)

message("Importing variable genes from TXT file ...")
hvgs <- scan(snakemake@input[["hvgs"]], what = character())
message("Done.")

message("Loading sample ... ")
sce <- readRDS(snakemake@input[["sce"]])
message("* Number of cells: ", ncol(sce))
message("* Number of feature: ", nrow(sce))
message("Done.")

message("Preparing batch variable ...")
sample_metadata_table <- read_tsv("config/samples.tsv") %>%
  column_to_rownames("sample_name")
metadata_barcodes_factor <- yaml::read_yaml("config/config.yaml")[["metadata"]][["barcodes"]][["factor"]]
batch_factor <- factor(sample_metadata_table[colData(sce)[["sample"]], snakemake_params_batch], levels = metadata_barcodes_factor[[snakemake_params_batch]])
message("# Overview #")
table(batch_factor)
message("############")
message("Done.")

message("Apply fastMNN ...")
message("* Number of batches: ", length(unique(colData(sce)[[snakemake_params_batch]])))
sce <- fastMNN(
    sce,
    batch = batch_factor,
    k = snakemake_params_k,
    d = snakemake_params_d,
    get.variance = TRUE,
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
