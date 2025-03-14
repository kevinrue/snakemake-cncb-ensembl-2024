message("======== START ========")
message(strftime(Sys.time(), format = "%Y-%m-%d %H:%M:%OS", tz = "GMT", usetz = TRUE))
message("=======================")

suppressPackageStartupMessages(library(fishpond))
suppressPackageStartupMessages(library(rtracklayer))
suppressPackageStartupMessages(library(SummarizedExperiment))

simpleaf <- snakemake@input[["simpleaf"]]
gtf <- snakemake@input[["gtf"]]

message("Job configuration")
message("- simpleaf: ", simpleaf)
message("- gtf: ", gtf)

sample_name <- basename(simpleaf)

message("Loading simpleaf results ... ")
sce <- loadFry(fryDir = file.path(simpleaf, "af_quant"), outputFormat = "S+A", quiet = TRUE)
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Removing zero-UMI barcodes ... ")
umi_sum <- colSums(assay(sce, "counts"))
message("* Removing ", sum(umi_sum == 0), " barcodes.")
sce <- sce[, umi_sum > 0]
message("Done.")

message("Importing gene annotations from GTF file ...")
gtf_gene_data <- import.gff(gtf, feature.type = "gene")
message("Done.")

message("Replacing rowData with rowRanges ...")
names(gtf_gene_data) <- mcols(gtf_gene_data)[["gene_id"]]
stopifnot(all(rownames(sce) %in% names(gtf_gene_data)))
rowRanges(sce) <- gtf_gene_data[rownames(sce)]
message("Done.")

message("SCE object size: ", format(object.size(sce), unit = "GB"))

message("Saving to RDS file ...")
saveRDS(sce, snakemake@output[["sce"]])
message("Done.")

message("=======================")
message(strftime(Sys.time(), format = "%Y-%m-%d %H:%M:%OS", tz = "GMT", usetz = TRUE))
message("========== END ========")
