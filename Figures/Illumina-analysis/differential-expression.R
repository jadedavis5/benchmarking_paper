if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

#BiocManager::install("DESeq2")

#install.packages("VennDiagram")
#install.packages("ggVennDiagram")
#install.packages("RColorBrewer")
#install.packages("ggforce")

library(DESeq2)
library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(ggforce)
library(data.table)
library(ggVennDiagram)
library(VennDiagram)


meta <- read.table("metadata.csv", sep=",", header = TRUE)

mat <- read.table("rsem.merged.transcript_counts.tsv", sep="\t", header = TRUE, row.names=1)
mat <- mat[, -1] #take out transcript column
mat <- round(mat)
meta$group <- factor(meta$treatment, levels = c("ControlA","NB29A"))

data <- DESeqDataSetFromMatrix(countData=mat, colData=meta, design = ~group)

suppressMessages(
  dds <- DESeq(data)
)

vst <- vst(data, blind = FALSE)

mat.a <- assay(vst)
mat.a <- limma::removeBatchEffect(mat.a, vst$batch)
assay(vst) <- mat.a


### Compare treatments ###
#Compare controlA to NB29 infected
res <- results(dds, contrast=c("group", "NB29A" , "ControlA"))

cA.nbA <- subset(res, (padj <= 0.005 & !is.na(pvalue))& abs(log2FoldChange) >= 2 ) 
I <- data.frame(cA.nbA)
I$Group <- "Bec"
I$Transcript <- row.names(I)


### Find number of novel transcripts expressed ###
unique_transcripts <- readLines("STref_NOVEL_FINAL.txt")

matching_transcripts <- I %>%
  filter(Transcript %in% unique_transcripts)
