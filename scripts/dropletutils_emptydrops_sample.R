message(Sys.time())

suppressPackageStartupMessages({library(BiocParallel)})
suppressPackageStartupMessages({library(DropletUtils)})
suppressPackageStartupMessages({library(fishpond)})
suppressPackageStartupMessages({library(SummarizedExperiment)})

message("Job configuration")
message("- threads: ", snakemake@threads)
message("- lower: ", snakemake@params[["lower"]])
message("- niters: ", snakemake@params[["niters"]])
stopifnot(is.numeric(snakemake@threads))
stopifnot(is.numeric(snakemake@params[["lower"]]))
stopifnot(is.numeric(snakemake@params[["niters"]]))

sample_fry_dir <- file.path(snakemake@input[["alevin"]], "af_quant")
message("Input directory: ", sample_fry_dir)
stopifnot(dir.exists(sample_fry_dir))

message("Loading sample ... ")
sce <- loadFry(fryDir = sample_fry_dir, outputFormat = "S+A", quiet = TRUE)
message("Done.")

message("Running emptyDrops ...")
set.seed(100)
emptydrops_out <- emptyDrops(
    m = assay(sce, "counts"),
    lower = snakemake@params[["lower"]],
    niters = snakemake@params[["niters"]],
    BPPARAM = MulticoreParam(workers = as.integer(snakemake@threads))
)
message("Done.")

message("Saving to TSV file ...")
write_tsv(
    emptydrops_out %>% as.data.frame() %>% as_tibble(),
    snakemake@output[["tsv"]]
)
message("Done.")

message(Sys.time())
