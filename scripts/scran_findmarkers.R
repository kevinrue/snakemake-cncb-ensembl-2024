message("======== START ========")
message(strftime(Sys.time(), format = "%Y-%m-%d %H:%M:%OS", tz = "GMT", usetz = TRUE))
message("=======================")

suppressPackageStartupMessages(library(BiocParallel))
suppressPackageStartupMessages(library(SingleCellExperiment))
suppressPackageStartupMessages(library(scran))

message("Job configuration")
message("- logcounts: ", snakemake@input[["logcounts"]])
message("- clusters: ", snakemake@input[["clusters"]])
message("- block: ", snakemake@params[["block"]])
message("- lfc: ", snakemake@params[["lfc"]])
message("- threads: ", snakemake@threads)

message("Importing SCE from RDS file ...")
sce <- readRDS(snakemake@input[["logcounts"]])
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Importing clustering results ...")
clusters <- readRDS(snakemake@input[["clusters"]])
sce[["clusters"]] <- clusters[colnames(sce)]
message("Done.")

message("Running findMarkers ...")
markers <- findMarkers(
  x = sce,
  groups = colData(sce)[["clusters"]],
  test.type = "t",
  block = colData(sce)[[snakemake@params[["block"]]]],
  direction = "up",
  lfc = snakemake@params[["lfc"]],
  BPPARAM = MulticoreParam(workers = snakemake@threads)
)
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Saving results to RDS file ...")
saveRDS(markers, snakemake@output[["rds"]])
message("Done.")

message("=======================")
message(strftime(Sys.time(), format = "%Y-%m-%d %H:%M:%OS", tz = "GMT", usetz = TRUE))
message("========== END ========")
