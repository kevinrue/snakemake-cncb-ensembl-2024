library(rtracklayer)
library(tidyverse)

gtf_file <- "resources/genome/genome.gtf.gz"

gtf_gene_data <- import.gff(gtf_file, feature.type = "gene")

gtf_gene_data %>%
  as_tibble()
