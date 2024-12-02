message(Sys.time())

suppressPackageStartupMessages({library(fishpond)})
suppressPackageStartupMessages({library(SummarizedExperiment)})

stopifnot(nzchar(snakemake@output[["rds"]]))

alevin_quant_dir <- dirname(snakemake@input[[1]])
stopifnot(nzchar(alevin_quant_dir))
message("Input directory: ", alevin_quant_dir)

sample_basedirs <- list.files(path = alevin_quant_dir, include.dirs = TRUE)
stopifnot(length(sample_basedirs) > 0)
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
saveRDS(sce, snakemake@output[["rds"]])
message("Done.")

message(Sys.time())
