message(Sys.time())

suppressPackageStartupMessages({library(scran)})

message("Job configuration")
message("- prop: ", snakemake@params[["prop"]])

message("Importing modelGeneVar results from RDS file ...")
dec <- readRDS(snakemake@input[["rds"]])
message("Done.")

message("Selecting highly variable genes ...")
chosen <- getTopHVGs(
    dec,
    prop = snakemake@params[["prop"]]
)
message("Done.")

message("Writing highly variable genes to TXT ...")
write(chosen, snakemake@output[["hvgs"]])
message("Done.")

message(Sys.time())
