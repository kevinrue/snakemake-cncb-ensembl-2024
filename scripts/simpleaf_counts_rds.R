message(Sys.time())

suppressPackageStartupMessages({library(fishpond)})
suppressPackageStartupMessages({library(SummarizedExperiment)})

stopifnot(dir.exists(snakemake@input[["simpleaf"]]))
stopifnot(nzchar(snakemake@output[["rds"]]))

sample_name <- basename(snakemake@input[["simpleaf"]])

message("Loading simpleaf results ... ")
sce <- loadFry(fryDir = file.path(snakemake@input[["simpleaf"]], "af_quant"), outputFormat = "S+A", quiet = TRUE)
message("Done.")

message("Removing zero-UMI barcodes ... ")
umi_sum <- colSums(assay(sce, "counts"))
message("* Removing ", sum(umi_sum == 0), " barcodes.")
sce <- sce[, umi_sum > 0]
message("Done.")

message("Saving to RDS file ...")
saveRDS(sce, snakemake@output[["sce"]])
message("Done.")

message(Sys.time())
