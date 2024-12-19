message(Sys.time())

suppressPackageStartupMessages({library(fishpond)})
suppressPackageStartupMessages({library(SummarizedExperiment)})

stopifnot(dir.exists(snakemake@input[["simpleaf"]]))
stopifnot(nzchar(snakemake@output[["rds"]]))

sample_name <- basename(snakemake@input[["simpleaf"]])

message("Loading simpleaf results ... ")
sce <- loadFry(fryDir = file.path(snakemake@input[["simpleaf"]], "af_quant"), outputFormat = "S+A", quiet = TRUE)
message("Done.")

message("Adding sample name to colData ... ")
colData(sce)[["sample"]] <- sample_name
message("Done.")

message("Appending sample name to barcodes/colnames ... ")
colnames(sce) <- paste0(colnames(sce), "-", sample_name)
message("Done.")

message("Saving to RDS file ...")
saveRDS(sce, snakemake@output[["rds"]])
message("Done.")

message(Sys.time())
