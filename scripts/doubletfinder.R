message("======== START ========")
message(strftime(Sys.time(), format = "%Y-%m-%d %H:%M:%OS", tz = "GMT", usetz = TRUE))
message("=======================")

suppressPackageStartupMessages(library(DoubletFinder))
suppressPackageStartupMessages(library(SingleCellExperiment))
suppressPackageStartupMessages(library(Seurat))

if (exists("snakemake")) {
  sce_rds <- snakemake@input[["sce"]]
} else {
  sce_rds <- "results/before_scdblfinder/WPPp120hrs_rep2.rds"
}
n_pcs <- 20
pk <- 0.09
expected_doublet_rate <- 0.004 * 30

message("Job configuration")
message("- Input SCE: ", sce_rds)
message("- n_pcs: ", n_pcs)
message("- pk: ", pk)
message("- expected_doublet_rate: ", expected_doublet_rate)

message("Loading SCE object ...")
sce <- readRDS(sce_rds)

message("Creating Seurat object ...")
seu <- CreateSeuratObject(
  counts = assay(sce, "counts")
)

message("Removing SCE object ...")
rm(sce)

message("Run NormalizeData() ...")
seu <- NormalizeData(
  object = seu
)

message("Run e() ...")
seu <- FindVariableFeatures(
  object = seu,
  nfeatures = 2000
)

message("Run ScaleData() ...")
seu <- ScaleData(
  object = seu
)

message("Run RunPCA() ...")
seu <- RunPCA(
  object = seu,
  npcs = n_pcs
)

message("Determine number of expected doublets ...")
nExp_poi <- round(expected_doublet_rate * nrow(seu@meta.data))
message("Value: ", format(nExp_poi, big.mark = ","))

message("Run doubletFinder_v3() ...")
seu <- doubletFinder_v3(seu = seu, PCs = seq_len(n_pcs), pN = 0.25, pK = pk, nExp = nExp_poi, reuse.pANN = FALSE, sct = FALSE)

saveRDS(seu, snakemake@output[["sce"]])

message("=======================")
message(strftime(Sys.time(), format = "%Y-%m-%d %H:%M:%OS", tz = "GMT", usetz = TRUE))
message("========== END ========")
