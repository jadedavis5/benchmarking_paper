#install.packages("UpSetR")
library(UpSetR)

##Ref guided
tracking <- read.table("refguided-gffcmp.tracking", header = FALSE, sep="\t", stringsAsFactors = FALSE)

colnames(tracking) <- c("frag_id","locus","ref-gene-id","class-code","FLAMES","BAMBU","FLAIR","IsoQuant","StringTie3", "RGT Planet")
tools <- tracking[,5:10]
tools_bin <- as.data.frame(lapply(tools, function(x) ifelse(x == "-", 0, 1))) #record presence or absence 
rownames(tools_bin) <- sub("\\|.*", "", tracking$frag_id)
tools_list <- lapply(tools_bin, function(col) rownames(tools_bin)[col == 1])

#Make plot
upset(fromList(tools_list), order.by = "freq", sets=names(tools_list))

#Look at examples where RGT Planet has unique transcripts
library(dplyr)
RGT_unique <- tools_bin %>%
  filter(RGTPlanet == 1 & rowSums(select(.,-RGTPlanet)) == 0)



##De novo
tracking <- read.table("denovo-gffcmp.tracking", header = FALSE, sep="\t", stringsAsFactors = FALSE)

colnames(tracking) <- c("frag_id","locus","ref-gene-id","class-code","BAMBU","IsoQuant","StringTie3")
tools <- tracking[,5:7]
tools_bin <- as.data.frame(lapply(tools, function(x) ifelse(x == "-", 0, 1))) #record presence or absence 
rownames(tools_bin) <- sub("\\|.*", "", tracking$frag_id)
tools_list <- lapply(tools_bin, function(col) rownames(tools_bin)[col == 1])

#Make plot
upset(fromList(tools_list), order.by = "freq", sets=names(tools_list))
