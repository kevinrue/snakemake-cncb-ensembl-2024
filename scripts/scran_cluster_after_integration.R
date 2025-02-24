message(Sys.time())

suppressPackageStartupMessages(library(SingleCellExperiment))
suppressPackageStartupMessages(library(scran))

snakemake_params_k <- snakemake@params[["k"]]

message("Job configuration")
message("- k: ", snakemake_params_k)

message("Importing SCE from RDS file ...")
sce <- readRDS(snakemake@input[["sce"]])
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Running clusterCells ...")
nn.clusters <- clusterCells(
  sce,
  use.dimred = "corrected",
  BLUSPARAM = NNGraphParam(k = snakemake_params_k)
)
message("Done.")

message("Post-process clusterCells results")
names(nn.clusters) <- colnames(sce)
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Saving SCE to RDS file ...")
saveRDS(sce, snakemake@output[["sce"]])
message("Done.")

message(Sys.time())
