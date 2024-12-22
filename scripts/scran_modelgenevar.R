message(Sys.time())

suppressPackageStartupMessages({library(BiocParallel)})
suppressPackageStartupMessages({library(SingleCellExperiment)})
suppressPackageStartupMessages({library(scran)})
suppressPackageStartupMessages({library(scuttle)})
suppressPackageStartupMessages({library(tidyverse)})

message("Job configuration")
message("- threads: ", snakemake@threads)
message("- HVGs proportion:", snakemake@params[["hvgs_prop"]])

message("Importing SCE from RDS file ...")
sce <- readRDS(snakemake@input[["sce"]])
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

if (!"logcounts" %in% names(assays(sce))) {
    message("Computing log-normalisation ...")
    sce <- logNormCounts(sce, BPPARAM = MulticoreParam(workers = snakemake@threads))
    assay(sce, "counts") <- NULL
    message("Done.")   
}

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Model gene variance ...")
dec <- modelGeneVar(sce, BPPARAM = MulticoreParam(workers = snakemake@threads))
message("Done.")

message("Saving gene statistics to TSV file ...")
write_tsv(
    bind_cols(tibble(gene_id = rownames(dec)), as_tibble(dec)),
    snakemake@output[["tsv"]]
)
message("Done.")

message("Computing and plotting fit to PDF file ...")
fit <- metadata(dec)
pdf(snakemake@output[["fit"]], width = 7, height = 5)
plot(
    fit$mean, fit$var,
    xlab="Mean of log-expression",
    ylab="Variance of log-expression"
)
curve(fit$trend(x), col="dodgerblue", add=TRUE, lwd=2)
dev.off()
message("Done.")

message("Selecting highly variable genes ...")
chosen <- getTopHVGs(dec, prop = snakemake@params[["hvgs_prop"]])
message("Done.")

message("Writing highly variable genes to TXT ...")
write(chosen, snakemake@output[["hvgs"]])
message("Done.")

message(Sys.time())
