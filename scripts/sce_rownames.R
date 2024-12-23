message(Sys.time())

suppressPackageStartupMessages({library(SingleCellExperiment)})

message("Importing from RDS file ...")
sce <- readRDS(snakemake@input[["sce"]])
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Getting rownames ...")
sce_rownames <- rownames(sce)
message("Done.")

message("Removing SCE from session ...")
rm(sce)
message("Done.")

message("Writing rownames to TXT ...")
write(sce_rownames, snakemake@output[["txt"]])
message("Done.")

message(Sys.time())
