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
n_top_hvgs <- snakemake@params[["n_top_hvgs"]]
n_pcs <- snakemake@params[["n_pcs"]]
exclude_hvgs_tsv <- snakemake@params[["exclude_hvgs"]]
threads <- snakemake@threads

message("Job configuration")
message("- sce_rds: ", sce_rds)
message("- mt_tsv: ", mt_tsv)
message("- gtf: ", gtf)
message("- n_top_hvgs: ", n_top_hvgs)
message("- n_pcs: ", n_pcs)
message("- exclude_hvgs_tsv: ", exclude_hvgs_tsv)
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
  n = n_top_hvgs
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
  rank = 50, # TODO: parameterise
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
for (resolution in seq(from = 0.2, to = 2, by = 0.2)) {
  cluster_coldata_name <- paste0("cluster_louvain_res", resolution)
  set.seed(1010)
  colData(sce)[[cluster_coldata_name]] <- clusterRows(
    x = reducedDim(sce, "PCA")[, seq_len(n_pcs)],
    BLUSPARAM = TwoStepParam(
      first = KmeansParam(
        centers = 1000,
        iter.max = 100
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
          resolution = resolution
        )
      )
    ),
    full = FALSE
  )
}
message("Done.")

message("Running clusterRows (walktrap) ...")
for (steps in 4 * 2^seq(from = 0, to = 2, by = 1)) {
  cluster_coldata_name <- paste0("cluster_walktrap_steps", steps)
  set.seed(1010)
  colData(sce)[[cluster_coldata_name]] <- clusterRows(
    x = reducedDim(sce, "PCA")[, 1:50],
    BLUSPARAM = TwoStepParam(
      first = KmeansParam(
        centers = 1000,
        iter.max = 100
      ),
      second = NNGraphParam(
        shared = TRUE,
        k = 5,
        BNPARAM = KmknnParam(
          distance = "Euclidean"
        ),
        BPPARAM = MulticoreParam(workers = threads),
        cluster.fun = "walktrap",
        cluster.args = list(
          steps = steps
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
