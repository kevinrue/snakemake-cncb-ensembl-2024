message(Sys.time())

suppressPackageStartupMessages({library(fishpond)})
suppressPackageStartupMessages({library(SummarizedExperiment)})

message("Job configuration: None")
message("- expect_cells: ", snakemake@params[["expect_cells"]])
stopifnot(is.numeric(snakemake@params[["expect_cells"]]))

sample_fry_dir <- file.path(snakemake@input[["alevin"]], "af_quant")
message("Input directory: ", sample_fry_dir)
stopifnot(dir.exists(sample_fry_dir))

message("Loading sample ... ")
sce <- loadFry(fryDir = sample_fry_dir, outputFormat = "S+A", quiet = TRUE)
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Identifying lower UMI count for expected cell number  ...")
umi_sum <- colSums(assay(sce, "counts"))
umi_lower <- sort(umi_sum, decreasing = TRUE)[snakemake@params[["expect_cells"]]]
message("Done.")

message("Saving to TXT file ...")
write(umi_lower, snakemake@output[["txt"]])
message("Done.")

message(Sys.time())
