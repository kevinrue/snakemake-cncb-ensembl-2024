message(Sys.time())
suppressPackageStartupMessages({library(bluster)})
suppressPackageStartupMessages({library(BiocSingular)})
suppressPackageStartupMessages({library(cowplot)})
suppressPackageStartupMessages({library(ggplot2)})
suppressPackageStartupMessages({library(rtracklayer)})
suppressPackageStartupMessages({library(SingleCellExperiment)})
suppressPackageStartupMessages({library(scater)})
suppressPackageStartupMessages({library(scran)})
suppressPackageStartupMessages({library(scuttle)})

message("Importing from RDS file ...")
TODO
message("Done.")

message("Writing to HDF5 file ...")
sce <- saveHDF5SummarizedExperiment(
  x = sce,
  dir = dirname(snakemake@output[[1]]),
  prefix = "all-")
message("Done.")

message(Sys.time())
