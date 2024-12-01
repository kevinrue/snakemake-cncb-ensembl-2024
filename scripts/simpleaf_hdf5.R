message(Sys.time())

.libPaths("/ceph/project/cncb/albrecht/R-4.4.1")
cat("Library path:\n")
print(.libPaths("/ceph/project/cncb/albrecht/R-4.4.1"))

suppressPackageStartupMessages({library(SingleCellExperiment)})
suppressPackageStartupMessages({library(HDF5Array)})

message("Importing from RDS file ...")
sce <- readRDS("/ceph/project/cncb/albrecht/snakemake-cncb-ensembl-2024/results/test/sce.rds")
message("Done.")

message("Writing to HDF5 file ...")
sce <- saveHDF5SummarizedExperiment(
  x = sce,
  dir = "/ceph/project/cncb/albrecht/snakemake-cncb-ensembl-2024/results/test/hdf5",
  prefix = "sce-")
message("Done.")

message(Sys.time())
