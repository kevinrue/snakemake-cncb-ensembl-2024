message(Sys.time())

suppressPackageStartupMessages({library(org.Dm.eg.db)})
suppressPackageStartupMessages({library(clusterProfiler)})
suppressPackageStartupMessages({library(readr)})

message("Importing genes from TXT file ...")
hvgs_ids <- scan(snakemake@input[["hvgs"]], what = "character")
message("Done.")

message("Importing background genes from TXT file ...")
background_ids <- scan(snakemake@input[["bg"]], what = "character")
message("Done.")

message("Running enrichGO ...")
ego <- enrichGO(gene          = hvgs_ids,
                universe      = background_ids,
                OrgDb         = org.Dm.eg.db,
                keyType       = "FLYBASE",
                ont           = "ALL",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.01,
                qvalueCutoff  = 0.05,
                readable      = TRUE)
message("Done.")

message("Saving enrichGO results to TSV file ...")
saveRDS(ego, snakemake@output[["rds"]])
message("Done.")

message(Sys.time())
