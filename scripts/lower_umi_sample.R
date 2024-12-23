message(Sys.time())

suppressPackageStartupMessages({library(fishpond)})
suppressPackageStartupMessages({library(SingleCellExperiment)})

message("Job configuration: None")
message("- expect_cells: ", snakemake@params[["expect_cells"]])
stopifnot(is.numeric(snakemake@params[["expect_cells"]]))

message("Loading sample ... ")
sce <- readRDS(snakemake@input[["sce"]])
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Identifying lower UMI count for expected cell number  ...")
umi_sum <- colSums(assay(sce, "counts"))
umi_lower <- sort(umi_sum, decreasing = TRUE)[snakemake@params[["expect_cells"]]]
message("Done.")

message("Saving to TXT file ...")
write(umi_lower, snakemake@output[["txt"]])
message("Done.")

message(Sys.time())
