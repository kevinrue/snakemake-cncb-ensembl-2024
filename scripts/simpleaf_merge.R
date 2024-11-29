message(Sys.time())

.libPaths("/ceph/project/cncb/albrecht/R-4.4.1")
cat("Library path:\n")
print(.libPaths("/ceph/project/cncb/albrecht/R-4.4.1"))

suppressPackageStartupMessages({library(fishpond)})
suppressPackageStartupMessages({library(SummarizedExperiment)})

alevin_quant_dir <- "/ceph/project/cncb/albrecht/snakemake-cncb-ensembl-2024/results/alevin"

sample_basedirs <- list.files(path = alevin_quant_dir, include.dirs = TRUE)
message("Detected ", length(sample_basedirs), " samples.")

message("Loading samples ... ")
sce_list <- list()
for (sample_basedir in sample_basedirs) {
  message("- ", sample_basedir)
  message("  * loadFry")
  sce <- loadFry(fryDir = file.path(alevin_quant_dir, sample_basedir, "af_quant"), outputFormat = "S+A", quiet = TRUE)
  message("  * Filter barcode below 100 UMI")
  umi_sum <- colSums(assay(sce, "counts"))
  sce <- sce[, umi_sum >= 100]
  # message("  * writeHDF5Array")
  # assay(sce, "counts") <- writeHDF5Array(assay(sce, "counts"))
  # sce <- SingleCellExperiment(assays = list(counts = writeHDF5Array(assay(sce1, "counts"))))
  sce$sample <- sample_basedir
  colnames(sce) <- paste0(colnames(sce), "-", sample_basedir)
  sce_list[[sample_basedir]] <- sce
  message("  * Added to list")
  rm(sce)
}
message("Done.")

# Merge
message("Merge all samples ...")
sce <- do.call("cbind", sce_list)
message("Done.")

message("Saving to RDS file ...")
saveRDS(sce, "/ceph/project/cncb/albrecht/snakemake-cncb-ensembl-2024/results/test/sce.rds")
message("Done.")

message(Sys.time())
