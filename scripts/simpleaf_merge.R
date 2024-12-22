message(Sys.time())

suppressPackageStartupMessages({library(SummarizedExperiment)})

message("Loading samples ... ")
sce_list <- list()
for (rds_file in snakemake@input) {
  sample_name <- basename(rds_file)
  message("- ", rds_file)
  message("  * readRDS")
  sce <- readRDS(rds_file)
  message("  * Adding sample name to colData")
  colData(sce)[["sample"]] <- sample_name
  message("  * Appending sample name to colnames")
  colnames(sce) <- paste0(colnames(sce), "-", sample_name)
  sce_list[[sample_name]] <- sce
  message("  * Added to list")
  rm(sce)
}
message("Done.")

message("Checking that feature identifiers match ... ")
feature_ids_1 <- rownames(assay(sce_list[[1]], "counts"))
for (sce2 in sce_list) {
  feature_ids_2 <- rownames(assay(sce2, "counts"))
  if (!identical(feature_ids_1, feature_ids_2)) {
    stop("Feature identifiers do not match.")
  }
}
message("Done.")

message("Merging all samples ...")
sce <- do.call("cbind", sce_list)
message("Done.")

message("Saving to RDS file ...")
saveRDS(sce, snakemake@output[["rds"]])
message("Done.")

message(Sys.time())
