message(Sys.time())

suppressPackageStartupMessages({library(BiocParallel)})
suppressPackageStartupMessages({library(DropletUtils)})
suppressPackageStartupMessages({library(SingleCellExperiment)})

message("Job configuration")
message("- threads: ", snakemake@threads)
stopifnot(is.numeric(snakemake@threads))

lower_file <- snakemake@input[["lower"]]
message("Lower file: ", lower_file)
stopifnot(file.exists(lower_file))

message("Loading lower UMI threshold for expected cell number ... ")
lower <- scan(lower_file, what = integer(), quiet = TRUE)
message("Done.")

message("lower: ", format(lower, big.mark = ","))

message("Loading sample ... ")
sce <- readRDS(snakemake@input[["sce"]])
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
