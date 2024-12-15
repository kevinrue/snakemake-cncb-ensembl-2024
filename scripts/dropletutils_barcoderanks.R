message(Sys.time())

suppressPackageStartupMessages({library(BiocParallel)})
suppressPackageStartupMessages({library(DropletUtils)})
suppressPackageStartupMessages({library(fishpond)})
suppressPackageStartupMessages({library(SummarizedExperiment)})

message("Job configuration")
message("- threads: ", snakemake@threads)
message("- lower: ", snakemake@params[["lower"]])
stopifnot(is.numeric(snakemake@threads))
stopifnot(is.numeric(snakemake@params[["lower"]]))

sample_fry_dir <- file.path(snakemake@input[["alevin"]], "af_quant")
message("Input directory: ", sample_fry_dir)
stopifnot(dir.exists(sample_fry_dir))

message("Loading sample ... ")
sce <- loadFry(fryDir = sample_fry_dir, outputFormat = "S+A", quiet = TRUE)
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Running barcodeRanks ...")
set.seed(100)
barcoderanks_out <- barcodeRanks(
    m = sce,
    lower = snakemake@params[["lower"]],
    assay.type = "counts",
    BPPARAM = MulticoreParam(workers = as.integer(snakemake@threads))
)
message("Done.")

message("Saving to RDS file ...")
saveRDS(barcoderanks_out, snakemake@output[["rds"]])
message("Done.")

message(Sys.time())
