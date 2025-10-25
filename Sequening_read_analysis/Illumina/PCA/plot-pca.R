#Make PCA plot from nf-core rnaseq run rsem merged gene counts

library(DESeq2)
library(ggplot2)
library(RColorBrewer)

#Format data
meta <- read.table("metadata.csv", sep=",", header = TRUE)
mat <- read.table("rsem.merged.gene_counts.tsv", sep="\t", header = TRUE, row.names=1)
meta$Group <- factor(meta$treatment, levels = c("Control","NB29"))

mat2 <- mat[, -1] #take out transcript column
mat3 <- round(mat2)

#DeSeq
data <- DESeqDataSetFromMatrix(countData=mat3, colData=meta, design = ~Group)

suppressMessages(
  dds <- DESeq(data)
)

norm.counts <- counts(dds, normalized=TRUE)
norm.counts <- log2(norm.counts + 1)
vst <- vst(data, blind = FALSE)
mat.a <- assay(vst)
mat.a <- limma::removeBatchEffect(mat.a, vst$batch)
assay(vst) <- mat.a

#Make plot
set <-  colorRampPalette(brewer.pal(7, "Dark2"))(7)

png("PCA-elip.png", height = 10, width=12, units ="in", res=350)

pcaData <- plotPCA(vst, intgroup = c("treatment"), returnData = TRUE, ntop = 500)
percentVar <- round(100 * attr(pcaData, "percentVar")) 

p <- ggplot(pcaData, aes(x = PC1, y = PC2,  color=group,  label=name)) + 
  geom_point(size =3) + 
  xlab(paste0("PC1: ", percentVar[1], "% variance")) + 
  ylab(paste0("PC2: ", percentVar[2], "% variance")) + 
  ggtitle("PCA, variance stabilised") +
  theme(panel.grid = element_blank(), panel.border = element_rect(fill= "transparent"),
        axis.text=element_text(size=16), #text=element_text(family="Calibri"),
        axis.title=element_text(size=18, face="bold"), 
        legend.text=element_text(size=18), legend.title=element_text(size=18, face="bold"),
        strip.text = element_text(size = 16, face = "bold")) +
  scale_color_manual(values = set) + geom_point(size = 5)

p
dev.off()
