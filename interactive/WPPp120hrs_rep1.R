library(iSEE)
library(SingleCellExperiment)
library(scater)
sce <- readRDS("test-after-emptydrops/WPPp120hrs_rep1.rds")
rownames(sce) <- uniquifyFeatureNames(ID = rowData(sce)[["gene_id"]], names = rowData(sce)[["gene_name"]])
app <- iSEE(
  se = sce,
  initial = list(
    ReducedDimensionPlot(
      PanelWidth = 4L,
      Type = "UMAP", PointSize = 0.01
    ),
    ReducedDimensionPlot(
      PanelWidth = 4L,
      Type = "UMAP", PointSize = 0.01,
      ColorBy = "Feature name", ColorByFeatureSource = "RowDataTable1"
    ),
    ReducedDimensionPlot(
      PanelWidth = 4L,
      Type = "UMAP", PointSize = 0.01,
      ColorBy = "Feature name", ColorByFeatureName = "lncRNA:roX1"
    )
  )
)
if (interactive()) {
  shiny::runApp(appDir = app, launch.browser = TRUE)
}
