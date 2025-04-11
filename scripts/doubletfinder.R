message("======== START ========")
message(strftime(Sys.time(), format = "%Y-%m-%d %H:%M:%OS", tz = "GMT", usetz = TRUE))
message("=======================")

suppressPackageStartupMessages(library(DoubletFinder))

print(packageVersion("DoubletFinder"))

file.create(snakemake@output[[1]])

message("=======================")
message(strftime(Sys.time(), format = "%Y-%m-%d %H:%M:%OS", tz = "GMT", usetz = TRUE))
message("========== END ========")
