if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
#install.packages('arrangements')
library(arrangements)
BiocManager::install("FLAMES")

library(BiocFileCache)
library(FLAMES)


temp_path <- tempfile()
bfc <- BiocFileCache::BiocFileCache(temp_path, ask = FALSE)

annotation <- bfc[[names(BiocFileCache::bfcadd(bfc, "RGT_Planet_v2.gff", "../analysis_files/RGT_Planet_v2.gff"))]]
fastq <- bfc[[names(BiocFileCache::bfcadd(bfc, "merged.fastq.gz", "merged.fastq.gz"))]]
genome_fa <- bfc[[names(BiocFileCache::bfcadd(bfc, "220816_RGT_Planet_pseudomolecules_and_unplaced_contigs_CPclean.fasta", "../analysis_files/220816_RGT_Planet_pseudomolecules_and_unplaced_contigs_CPclean.fasta"))]]
  outdir <- tempfile()
dir.create(outdir)


se <- bulk_long_pipeline(
  annotation = annotation,
  genome_fa = genome_fa,
  fastq = fastq,
  outdir = outdir,
  minimap2 = NULL,
  config_file = "config.json")
