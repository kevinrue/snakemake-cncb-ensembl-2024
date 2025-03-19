message("======== START ========")
message(strftime(Sys.time(), format = "%Y-%m-%d %H:%M:%OS", tz = "GMT", usetz = TRUE))
message("=======================")

suppressPackageStartupMessages(library(BiocNeighbors))
suppressPackageStartupMessages(library(BiocParallel))
suppressPackageStartupMessages(library(BiocSingular))
suppressPackageStartupMessages(library(bluster))
suppressPackageStartupMessages(library(cowplot))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(ggrastr))
suppressPackageStartupMessages(library(rtracklayer))
suppressPackageStartupMessages(library(scales))
suppressPackageStartupMessages(library(scater))
suppressPackageStartupMessages(library(scran))
suppressPackageStartupMessages(library(SingleCellExperiment))
suppressPackageStartupMessages(library(tidyverse))

sce_rds <- snakemake@input[["sce"]]
mt_tsv <- snakemake@input[["mt"]]
gtf <- snakemake@input[["gtf"]]

n_hvgs <- snakemake@params[["n_hvgs"]]
exclude_hvgs_tsv <- snakemake@params[["exclude_hvgs"]]
n_pcs <- snakemake@params[["n_pcs"]]
cluster_kmeans_centers <- snakemake@params[["cluster_kmeans_centers"]]
cluster_kmeans_iter_max <- snakemake@params[["cluster_kmeans_iter_max"]]
cluster_louvain_resolutions <- snakemake@params[["cluster_louvain_resolutions"]]
cluster_walktrap_steps <- snakemake@params[["cluster_walktrap_steps"]]

threads <- snakemake@threads

message("Job configuration")

message("- sce_rds: ", sce_rds)
message("- mt_tsv: ", mt_tsv)
message("- gtf: ", gtf)

message("- n_hvgs: ", format(n_hvgs, big.mark = ","))
message("- exclude_hvgs_tsv: ", exclude_hvgs_tsv)
message("- n_pcs: ", format(n_pcs, big.mark = ","))
message("- cluster_kmeans_centers: ", format(cluster_kmeans_centers, big.mark = ","))
message("- cluster_kmeans_iter_max: ", format(cluster_kmeans_iter_max, big.mark = ","))
message("- cluster_louvain_resolutions: ", paste0(cluster_louvain_resolutions, collapse = ", "))
message("- cluster_walktrap_steps: ", paste0(cluster_walktrap_steps, collapse = ", "))

message("- threads: ", threads)

message("Importing SCE from RDS file ...")
sce <- readRDS(sce_rds)
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Importing mitochondrial genes from RDS file ...")
mito_gene_ids <- read_tsv(mt_tsv, show_col_types = FALSE)[["gene_id"]]
message("Done.")

message("Adding mitochondrial annotations to SCE object ...")
rowData(sce)[["mt"]] <- rownames(sce) %in% mito_gene_ids
message("Done.")

message("Importing gene annotations from GTF file ...")
gtf_gene_data <- import.gff(gtf, feature.type = "gene")
message("Done.")

message("Adding gene annotations to SCE object ...")
new_rowdata <- gtf_gene_data %>%
  as_tibble() %>%
  as("DataFrame")
rownames(new_rowdata) <- new_rowdata[["gene_id"]]
rowData(sce) <- cbind(rowData(sce), new_rowdata[rownames(sce), ])
message("Done.")

message("Running logNormCounts ...")
sce <- logNormCounts(
  x = sce,
  BPPARAM = MulticoreParam(workers = threads)
)
message("Done.")

message("Running modelGeneVar ...")
dec <- modelGeneVar(
  x = sce,
  BPPARAM = MulticoreParam(workers = threads)
)
rowData(sce)[["modelGeneVar"]] <- dec
message("Done.")

message("Running getTopHVGs ...")
hvgs <- getTopHVGs(
  stats = dec,
  n = n_hvgs
)
message("Done.")

message("Removing curated genes from hvgs ...")
exclude_hvgs <- read_tsv(exclude_hvgs_tsv)[["gene_id"]]
hvgs <- setdiff(hvgs, exclude_hvgs)
message("Done.")

message("Remaining HVGs: ", length(hvgs))

message("Adding HVG information to SCE ...")
rowData(sce)[["hvg"]] <- rownames(sce) %in% hvgs
message("Done.")

message("Running fixedPCA ...")
set.seed(1010)
sce <- fixedPCA(
  x = sce,
  rank = n_pcs,
  subset.row = hvgs,
  BPPARAM = MulticoreParam(workers = threads)
)
message("Done.")

message("Running runUMAP ...")
set.seed(1010)
sce <- runUMAP(
  x = sce,
  dimred = "PCA",
  n_dimred = n_pcs,
  BPPARAM = MulticoreParam(workers = threads)
)
message("Done.")

message("Running clusterRows (louvain) ...")
for (i_resolution in cluster_louvain_resolutions) {
  cluster_coldata_name <- paste0("cluster_louvain_res", i_resolution)
  set.seed(1010)
  colData(sce)[[cluster_coldata_name]] <- clusterRows(
    x = reducedDim(sce, "PCA"),
    BLUSPARAM = TwoStepParam(
      first = KmeansParam(
        centers = cluster_kmeans_centers,
        iter.max = cluster_kmeans_iter_max
      ),
      second = NNGraphParam(
        shared = TRUE,
        k = 5,
        BNPARAM = KmknnParam(
          distance = "Euclidean"
        ),
        BPPARAM = MulticoreParam(workers = threads),
        cluster.fun = "louvain",
        cluster.args = list(
          resolution = i_resolution
        )
      )
    ),
    full = FALSE
  )
}
message("Done.")

message("Saving results to RDS file ...")
saveRDS(sce, snakemake@output[["sce"]])
message("Done.")

message("=======================")
message(strftime(Sys.time(), format = "%Y-%m-%d %H:%M:%OS", tz = "GMT", usetz = TRUE))
message("========== END ========")
