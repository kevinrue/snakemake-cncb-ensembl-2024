message("======== START ========")
message(strftime(Sys.time(), format = "%Y-%m-%d %H:%M:%OS", tz = "GMT", usetz = TRUE))
message("=======================")

suppressPackageStartupMessages(library(BiocParallel))
suppressPackageStartupMessages(library(SingleCellExperiment))
suppressPackageStartupMessages(library(scDblFinder))

sce_rds <- snakemake@input[["sce"]]
scdblfinder_clusters <- snakemake@params[["clusters"]]
threads <- snakemake@threads

message("Job configuration")
message("- sce: ", sce_rds)
message("- clusters: ", scdblfinder_clusters)
message("- threads: ", threads)

message("Importing SCE from RDS file ...")
sce <- readRDS(sce_rds)
message("Done.")

## Better solution is to fix the parameter scan script to add this information as rowRanges instead of rowData
message("Temporarily remove conflicting columns of mcols() ...")
mcols_backup <- mcols(sce)
mcols(sce) <- NULL
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Running scDblFinder ...")
sce <- scDblFinder(
  sce = sce,
  clusters = scdblfinder_clusters,
  dbr.sd = 1, # disable doublet rate expectation
  returnType = "full",
  BPPARAM = MulticoreParam(workers = threads)
)
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Saving results to RDS file ...")
saveRDS(sce, snakemake@output[["sce"]])
message("Done.")

message("=======================")
message(strftime(Sys.time(), format = "%Y-%m-%d %H:%M:%OS", tz = "GMT", usetz = TRUE))
message("========== END ========")
