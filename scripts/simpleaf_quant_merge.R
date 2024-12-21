message(Sys.time())

suppressPackageStartupMessages({library(fishpond)})
suppressPackageStartupMessages({library(SummarizedExperiment)})

message("Loading samples ... ")
sce_list <- list()
for (simpleaf_sample_dir in snakemake@input) {
  sample_name <- basename(simpleaf_sample_dir)
  message("- ", sample_name)
  message("  * loadFry")
  sce <- loadFry(fryDir = file.path(simpleaf_sample_dir, "af_quant"), outputFormat = "S+A", quiet = TRUE)
  sce$sample <- sample_name
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

message("Removing zero-UMI barcodes ...")
umi_sum <- colSums(assay(sce, "counts"))
message(" - Barcodes with 0 UMI count: ", format(sum(umi_sum == 0), big.mark = ","))
sce <- sce[, umi_sum > 0]
message("Done.")

message("Saving to RDS file ...")
saveRDS(sce, snakemake@output[["rds"]])
message("Done.")

message(Sys.time())
