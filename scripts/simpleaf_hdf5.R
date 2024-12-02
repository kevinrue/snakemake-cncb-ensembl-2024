message(Sys.time())

suppressPackageStartupMessages({library(SingleCellExperiment)})
suppressPackageStartupMessages({library(HDF5Array)})

message("Importing from RDS file ...")
sce <- readRDS(snakemake@input[["rds"]])
message("Done.")

message("Writing to HDF5 file ...")
sce <- saveHDF5SummarizedExperiment(
  x = sce,
  dir = snakemake@output[["hdf5"]]
)
message("Done.")

message(Sys.time())
