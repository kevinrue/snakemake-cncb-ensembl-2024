message(Sys.time())

suppressPackageStartupMessages(library(bluster))
suppressPackageStartupMessages(library(SingleCellExperiment))
suppressPackageStartupMessages(library(scran))

snakemake_params_k <- snakemake@params[["k"]]
snakemake_threads <- snakemake@threads

message("Job configuration")
message("- k: ", snakemake_params_k)

message("Importing SCE from RDS file ...")
sce <- readRDS(snakemake@input[["rds"]])
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

# Source: https://bioconductor.org/books/3.19/OSCA.workflows/hca-human-bone-marrow-10x-genomics.html#clustering-12
message("Running clusterCells ...")
set.seed(1000)
nn.clusters <- clusterRows(
  reducedDim(sce, "corrected"),
  TwoStepParam(
    KmeansParam(centers = 1000),
    NNGraphParam(
      k = snakemake_params_k
    )
  )
)
message("Done.")

message("Post-process clusterCells results")
names(nn.clusters) <- colnames(sce)
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Saving SCE to RDS file ...")
saveRDS(nn.clusters, snakemake@output[["rds"]])
message("Done.")

message(Sys.time())
