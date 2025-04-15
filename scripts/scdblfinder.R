message("======== START ========")
message(strftime(Sys.time(), format = "%Y-%m-%d %H:%M:%OS", tz = "GMT", usetz = TRUE))
message("=======================")

suppressPackageStartupMessages(library(BiocParallel))
suppressPackageStartupMessages(library(SingleCellExperiment))
suppressPackageStartupMessages(library(scDblFinder))

sce_rds <- snakemake@input[["sce"]]
scdblfinder_clusters <- snakemake@params[["clusters"]]
doublet_rate_per_1k <- snakemake@params[["doublet_rate_per_thousand"]]
scdblfinder_npcs <- snakemake@params[["npcs"]]
threads <- snakemake@threads

if (is.nan(scdblfinder_clusters)) {
  scdblfinder_clusters <- NULL
}

message("Job configuration")
message("- sce: ", sce_rds)
message("- clusters: ", scdblfinder_clusters)
message("- doublet_rate_per_1k: ", doublet_rate_per_1k)
message("- npcs: ", scdblfinder_npcs)
message("- threads: ", threads)



message("Importing SCE from RDS file ...")
sce <- readRDS(sce_rds)
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

dbr <- doublet_rate_per_1k * ncol(sce) / 1E3
message("Expected doublet rate: ", format(dbr * 100, digits = 3), "%")

hvgs <- rownames(sce)[which(rowData(sce)[["hvg"]])]
message("Number of highly variable genes: ", format(length(hvgs), big.mark = ","))

message("Running scDblFinder ...")
sce <- scDblFinder(
  sce = sce,
  clusters = scdblfinder_clusters,
  artificialDoublets = NULL,
  dbr = dbr,
  dbr.sd = NULL,
  nfeatures = hvgs,
  dims = scdblfinder_npcs,
  k = NULL,
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
