message(Sys.time())

suppressPackageStartupMessages({library(BiocParallel)})
suppressPackageStartupMessages({library(SingleCellExperiment)})
suppressPackageStartupMessages({library(scuttle)})

message("Job configuration")
message("- threads: ", snakemake@threads)
message("- min_umis", snakemake@params["min_umis"])
message("- min_genes", snakemake@params["min_genes"])

message("Importing from RDS file ...")
sce <- readRDS(snakemake@input[["rds"]])
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Computing QC filters ...")
umi_sum <- colSums(assay(sce, "counts"))
genes <- colSums(assay(sce, "counts") > 0)
message("Done.")

message("Applying QC filters ...")
keep <- umi_sum >= snakemake@params["min_umis"] &
  genes >= snakemake@params["min_genes"]
sce <- sce[, keep]
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Log-normalise ...")
sce <- logNormCounts(sce, BPPARAM = MulticoreParam(workers = snakemake@threads))
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Remove assay 'counts' ...")
assay(sce, "counts") <- NULL
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Saving to RDS file ...")
saveRDS(sce, snakemake@output[["rds"]])
message("Done.")

message(Sys.time())
