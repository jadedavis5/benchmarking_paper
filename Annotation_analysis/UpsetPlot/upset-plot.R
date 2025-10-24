#install.packages("UpSetR")
library(UpSetR)
library(grid)

tracking <- read.table("refguided-gffcmp.tracking", header = FALSE, sep="\t", stringsAsFactors = FALSE)

colnames(tracking) <- c("frag_id","locus","ref-gene-id","class-code","FLAMES","Bambu","FLAIR","IsoQuant","StringTie3", "RGT Planet")
tools <- tracking[,5:10]
tools_bin <- as.data.frame(lapply(tools, function(x) ifelse(x == "-", 0, 1))) #record presence or absence 
rownames(tools_bin) <- sub("\\|.*", "", tracking$frag_id)
tools_list <- lapply(tools_bin, function(col) rownames(tools_bin)[col == 1])

#Make plot
png(filename = "refguided-upset-plot.png", units = 'in', width = 9, height = 5, res = 350)
upset(fromList(tools_list), order.by = "freq", sets=names(tools_list), 
      text.scale = c(1.3, 1.5, 1.3, 0.9, 1.3, 1), sets.x.label = "Total transcripts")

dev.off()

#Look at examples where RGT Planet has unique transcripts
library(dplyr)
#RGT_unique <- tools_bin %>%
#  filter(RGT Planet == 1 & rowSums(select(.,-RGT Planet)) == 0)



##De novo
tracking <- read.table("denovo-gffcmp.tracking", header = FALSE, sep="\t", stringsAsFactors = FALSE)

colnames(tracking) <- c("frag_id","locus","ref-gene-id","class-code","Bambu","IsoQuant","StringTie3")
tools <- tracking[,5:7]
tools_bin <- as.data.frame(lapply(tools, function(x) ifelse(x == "-", 0, 1))) #record presence or absence 
rownames(tools_bin) <- sub("\\|.*", "", tracking$frag_id)
tools_list <- lapply(tools_bin, function(col) rownames(tools_bin)[col == 1])

#Make plot
png(filename = "denovo-upset-plot.png", units = "in", width = 9, height = 5, res = 350)
upset(fromList(tools_list), order.by = "freq", sets=names(tools_list), 
      text.scale = c(1.3, 1.5, 1.3, 1, 1.3, 1), sets.x.label = "Total transcripts")
dev.off()

