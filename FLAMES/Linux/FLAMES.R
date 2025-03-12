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

#Run this on the terminal to add write permission to mounted storage drive 
#sudo chmod u+w /mnt/sdd/bfc

path=tempfile(pattern = "file", tmpdir = "/mnt/sdd/bfc", fileext = "db")
bfc <- BiocFileCache::BiocFileCache(path, ask = FALSE)

annotation <- bfc[[names(BiocFileCache::bfcadd(bfc, "RGT_Planet_v2.gff", "/mnt/sdd/files/RGT_Planet_v2.gff"))]]
genome_fa <- bfc[[names(BiocFileCache::bfcadd(bfc, "220816_RGT_Planet_pseudomolecules_and_unplaced_contigs_CPclean.fasta", "/mnt/sdd/files/220816_RGT_Planet_pseudomolecules_and_unplaced_contigs_CPclean.fasta"))]]

fastq1 <- bfc[[names(BiocFileCache::bfcadd(bfc, "control_fastq", "/mnt/sdd/files/rna_011_ptt_f32_control_chopper-filtered.fq.gz"))]]
fastq2 <- bfc[[names(BiocFileCache::bfcadd(bfc, "nb29_fastq", "/mnt/sdd/files/rna_011_ptt_f32_nb29_chopper-filtered.fq.gz"))]]

fastq_dir <- paste(path, "fastq_dir", sep = "/")
dir.create(fastq_dir)

file.copy(c(fastq1, fastq2), fastq_dir)
unlink(c(fastq1, fastq2)) 

outdir <- tempfile()
dir.create(outdir)


se <- bulk_long_pipeline(annotation = annotation, fastq = fastq_dir, outdir = outdir, genome_fa = genome_fa, config_file = "config.json")

