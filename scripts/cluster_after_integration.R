message(Sys.time())

suppressPackageStartupMessages(library(bluster))
suppressPackageStartupMessages(library(SingleCellExperiment))
suppressPackageStartupMessages(library(scran))

params_kmeans_centers <- snakemake@params[["kmeans_centers"]]
params_nn_k <- snakemake@params[["nn_k"]]
params_threads <- snakemake@threads

message("Job configuration")
message("- KmeansParam (centers): ", params_kmeans_centers)
message("- NNGraphParam (k): ", params_nn_k)

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
    KmeansParam(
      centers = params_kmeans_centers
    ),
    NNGraphParam(
      k = params_nn_k
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
