#Run Bambu with BAM files generated through pipeline

#Download packages
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
BiocManager::install("bambu", force=TRUE)
library(bambu)

################ Reference guided ################
sample <- list.files(path = ".", pattern = "rna_011_ptt_f32_.*\\.bam$")
genome <- "220816_RGT_Planet_pseudomolecules_and_unplaced_contigs_CPclean.fasta"

bambuAnnotations <- prepareAnnotations("RGT_Planet_v2_bambu.gtf")

#Make sure that the reference GTF input has  gene_id BEFORE transcript_id in the 9th column

seRG.discoveryOnly <- bambu(reads = sample, genome = genome, annotation = bambuAnnotations, quant = FALSE)
writeToGTF(seRG.discoveryOnly, "outputAnnotation_UNCLEAN_BAMBUref.gtf")

################ De novo ################
#0.1, 0.5, 0.75 and 1
#0.75- increase NDR error

seDENOVO.discoveryOnly <- bambu(reads = sample, genome = genome, annotation = NULL, NDR = 1.0, quant = FALSE)

writeToGTF(seDENOVO.discoveryOnly, "outputAnnotation_UNCLEAN_BAMBUnoref.gtf")
