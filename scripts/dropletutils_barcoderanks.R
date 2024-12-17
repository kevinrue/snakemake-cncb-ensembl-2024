message(Sys.time())

suppressPackageStartupMessages({library(BiocParallel)})
suppressPackageStartupMessages({library(DropletUtils)})
suppressPackageStartupMessages({library(fishpond)})
suppressPackageStartupMessages({library(SummarizedExperiment)})

message("Job configuration")
message("- threads: ", snakemake@threads)
stopifnot(is.numeric(snakemake@threads))

sample_fry_dir <- file.path(snakemake@input[["simpleaf"]], "af_quant")
message("Input directory: ", sample_fry_dir)
stopifnot(dir.exists(sample_fry_dir))

lower_file <- snakemake@input[["lower"]]
message("Lower file: ", lower_file)
stopifnot(file.exists(lower_file))

message("Loading lower UMI threshold for expected cell number ... ")
lower <- scan(lower_file, what = integer(), quiet = TRUE)
message("Done.")

message("lower: ", format(lower, big.mark = ","))

message("Loading sample ... ")
sce <- loadFry(fryDir = sample_fry_dir, outputFormat = "S+A", quiet = TRUE)
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Running barcodeRanks ...")
set.seed(100)
barcoderanks_out <- barcodeRanks(
    m = sce,
    lower = lower,
    assay.type = "counts",
    BPPARAM = MulticoreParam(workers = as.integer(snakemake@threads))
)
message("Done.")

message("Saving to RDS file ...")
saveRDS(barcoderanks_out, snakemake@output[["rds"]])
message("Done.")

message(Sys.time())
