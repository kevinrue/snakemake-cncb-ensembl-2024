message("======== START ========")
message(strftime(Sys.time(), format = "%Y-%m-%d %H:%M:%OS", tz = "GMT", usetz = TRUE))
message("=======================")

suppressPackageStartupMessages(library(BiocParallel))
suppressPackageStartupMessages(library(SingleCellExperiment))
suppressPackageStartupMessages(library(scDblFinder))

message("Job configuration")
message("- sce: ", snakemake@input[["sce"]])
message("- threads: ", snakemake@threads)

message("Importing SCE from RDS file ...")
sce <- readRDS(snakemake@input[["sce"]])
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Running scDblFinder ...")
sce <- scDblFinder(
  sce = sce,
  BPPARAM = MulticoreParam(workers = snakemake@threads)
)
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Saving results to RDS file ...")
saveRDS(sce, snakemake@output[["sce"]])
message("Done.")

message("=======================")
message(strftime(Sys.time(), format = "%Y-%m-%d %H:%M:%OS", tz = "GMT", usetz = TRUE))
message("========== END ========")
