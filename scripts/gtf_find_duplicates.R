message(Sys.time())

suppressPackageStartupMessages({library(rtracklayer)})
suppressPackageStartupMessages({library(tidyverse)})

message("Importing from GTF file ...")
gtf_data <- import(snakemake@input[["gtf"]])
message("Done.")

message("GRanges object size: ", format(object.size(sce), unit = "GB"))

message("Extracting gene metadata ...")
all_genes <- gtf_data %>%
  as.data.frame() %>%
  as_tibble() %>%
  filter(type == "gene") %>%
  select(seqnames, start, end, strand, gene_id, gene_name)
message("Done.")

message("Identifying genes with identical chr/start/end/strand coordinates ...")
duplicated_gene_boundaries <- all_genes[
  all_genes %>%
    select(seqnames, start, end, strand) %>%
    duplicated(), ]
duplicated_gene_ids <- duplicated_gene_boundaries %>%
  left_join(all_genes, by = join_by(seqnames, start, end, strand)) %>%
  pull(gene_id)
message("Done.")

message("Classifying identical/different gene models ...")
genes_compared <- tibble(
  primary_id = character(0),
  primary_name = character(0),
  secondary_id = character(0),
  secondary_name = character(0),
  status = factor(character(0), c("duplicate", "different"))
)
for (i in seq_len(nrow(dup2))) {
  # for (i in 1) {
  for_seqnames <- dup2 %>% filter(row_number() == i) %>% pull(seqnames)
  for_start <- dup2 %>% filter(row_number() == i) %>% pull(start)
  for_end <- dup2 %>% filter(row_number() == i) %>% pull(end)
  for_strand <- dup2 %>% filter(row_number() == i) %>% pull(strand)
  for_dup_gene_info <- all_coding_genes %>% filter(
    seqnames == for_seqnames & start == for_start & end == for_end & strand == for_strand
  ) %>%
    mutate(is_CG = grepl("^CG[[:digit:]]+$", gene_name)) %>%
    arrange(is_CG)
  geneid1 <- for_dup_gene_info %>% filter(row_number() == 1) %>% pull(gene_id)
  genename1 <- for_dup_gene_info %>% filter(row_number() == 1) %>% pull(gene_name)
  exons1 <- subset(gtf_data, gene_id == geneid1 & type == "exon")
  for (geneid2 in for_dup_gene_info %>% filter(row_number() != 1) %>% pull(gene_id)) {
    genename2 <- for_dup_gene_info %>% filter(gene_id == geneid2) %>% pull(gene_name)
    exons2 <- subset(gtf_data, gene_id == geneid2 & type == "exon")
    overlap_2in1 <- findOverlaps(query = exons2, subject = exons1, type = "within")
    overlap_1in2 <- findOverlaps(query = exons1, subject = exons2, type = "within")
    all_2in1 <- length(setdiff(seq_along(exons2), queryHits(overlap_2in1))) == 0
    all_1in2 <- length(setdiff(seq_along(exons1), queryHits(overlap_1in2))) == 0
    if (all_2in1 && all_1in2) {
      genes_compared <- bind_rows(
        genes_compared,
        tibble(
          primary_id = geneid1,
          primary_name = genename1,
          secondary_id = geneid2,
          secondary_name = genename2,
          status = "identical"
        )
      )
    } else {
      genes_compared <- bind_rows(
        genes_compared,
        tibble(
          primary_id = geneid1,
          primary_name = genename1,
          secondary_id = geneid2,
          secondary_name = genename2,
          status = "different"
        )
      )
    }
  }
}
message("Done.")

message("Writing comparison table to TSV ...")
write_tsv(genes_compared, snakemake@output[["tsv"]])
message("Done.")

message(Sys.time())
