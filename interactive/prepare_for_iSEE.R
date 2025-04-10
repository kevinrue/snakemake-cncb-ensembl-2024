library(iSEE)
library(scater)
library(SingleCellExperiment)
library(tidyverse)

sce_after_mt <- readRDS("results/filter_mitochondria/WPPp120hrs_rep2.rds")
# assays: counts
# rowRanges: GTF data
# colData: barcodes
sce_before_doublets <- readRDS("results/before_scdblfinder/WPPp120hrs_rep2.rds")
# class: SingleCellExperiment
# dim: 24278 29526
# metadata(0):
#   assays(2): counts logcounts
# rownames(24278): FBgn0038542 FBgn0051092 ... FBgn0085692 FBgn0267596
# rowData names(24): source type ... modelGeneVar hvg
# colnames(29526): AAACTCCGTGGAGCAT TATCATGGTTCACGGC ... AATGGCCTCTGTAAGT AGCGTCCGTGGCCTGT
# colData names(12): barcodes sizeFactor ... cluster_walktrap_steps8 cluster_walktrap_steps16
# reducedDimNames(2): PCA UMAP
# mainExpName: NULL
# altExpNames(0):

sce <- sce_before_doublets
rm(sce_before_doublets)

#
# Rename rownames for better user experience ----
#

rownames(sce) <- uniquifyFeatureNames(
  ID = rowData(sce)[["gene_id"]],
  names = rowData(sce)[["gene_name"]]

#
#  Remove genes with zero variance ----
#

sce <- sce[rowVars(logcounts(sce)) > 0, ]

saveRDS(sce, "iSEE_ccb.rds")
)

#
# Load gene sets of interest for future use ----
#

gmt_data <- readLines("config/custom_markers.gmt") %>%
  str_split("\t")
markers_list <- list()
for (i in seq_len(length(gmt_data))) {
  markers_list[[gmt_data[[i]][1]]] <- gmt_data[[i]][3:length(gmt_data[[i]])]
}
rm(gmt_data)

#
# Configure and launch iSEE
#

app <- iSEE(
  se = sce,
  initial = list(
    ReducedDimensionPlot(
      PanelWidth = 4L,
      Type = "UMAP", PointSize = 0.01,
      VisualBoxOpen = TRUE,
      ColorBy = "Feature name", ColorByFeatureName = "lncRNA:roX2"
    ),
    ReducedDimensionPlot(
      PanelWidth = 4L,
      Type = "UMAP", PointSize = 0.01,
      VisualBoxOpen = TRUE,
      ColorBy = "Feature name", ColorByFeatureName = "Imp"
    ),
    ReducedDimensionPlot(
      PanelWidth = 4L,
      Type = "UMAP", PointSize = 0.01,
      VisualBoxOpen = TRUE,
      ColorBy = "Feature name", ColorByFeatureName = "VAChT"
    )
  )
)

if (interactive()) {
  shiny::runApp(appDir = app, launch.browser = TRUE)
}
