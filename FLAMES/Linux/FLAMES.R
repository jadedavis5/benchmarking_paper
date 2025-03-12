if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

install.packages('devtools', dependecies=TRUE)
library(devtools)

#Update gcc and g++ so beachmat will compile 
#After creating ~/.R/Makevars file
Sys.getenv("R_MAKEVARS_USER") #Check if parameter set
file.exists("~/.R/Makevars") #Check that the file exists
Sys.setenv(R_MAKEVARS_USER="~/.R/Makevars")

BiocManager::install("remotes")
BiocManager::install("mritchielab/FLAMES")
library(FLAMES)


#Run FLAMES
library(BiocFileCache)

bfc <- BiocFileCache::BiocFileCache("/mnt/sdd/bfc", ask = FALSE)

annotation <- bfc[[names(BiocFileCache::bfcadd(bfc, "RGT_Planet_v2.gff", "/mnt/sdd/files/RGT_Planet_v2.gff"))]]
genome_fa <- bfc[[names(BiocFileCache::bfcadd(bfc, "220816_RGT_Planet_pseudomolecules_and_unplaced_contigs_CPclean.fasta", "/mnt/sdd/files/220816_RGT_Planet_pseudomolecules_and_unplaced_contigs_CPclean.fasta"))]]

fastq <- bfc[[names(BiocFileCache::bfcadd(bfc, "merged.fastq.gz", "merged.fastq.gz"))]]

outdir <- tempfile()
dir.create(outdir)


se <- bulk_long_pipeline()
