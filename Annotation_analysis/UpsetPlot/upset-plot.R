remove.packages("ComplexUpset")
install.packages("ComplexUpset", type = "source")
library(ComplexUpset)
library(ggplot2)
library(reshape2)
library(tidyr)
library(dplyr)

##Ref guided
tracking <- read.table("refguided-gffcmp.tracking", header = FALSE, sep="\t", stringsAsFactors = FALSE)
colnames(tracking) <- c("frag_id","locus","ref-gene-id","class-code","FLAMES","Bambu","FLAIR","IsoQuant","StringTie3", "RGT_Planet")
tools <- tracking[,5:9]
tools_bin <- as.data.frame(lapply(tools, function(x) ifelse(x == "-", 0, 1))) #make it binary
rownames(tools_bin) <- sub("\\|.*", "", tracking$frag_id) #use the fragment id


plot_data <- do.call(rbind, lapply(names(tools_bin), function(tool){
  genes <- rownames(tools_bin)[tools_bin[[tool]] == 1]
  data.frame(
    Gene = genes,
    Tool = tool,
    Type = ifelse(tracking$RGT_Planet[match(genes, sub("\\|.*", "", tracking$frag_id))] == "-", 
                  "Novel", "Known")
  )
})) #if the RGT Planet column is - then it is Novel 

#Make the data wide
plot_data_wide <- plot_data %>%
  mutate(Present = 1) %>%
  pivot_wider(names_from = Tool, values_from = Present, values_fill = 0)

#Plot
png(filename = "refguided-upset-plot.png", units = 'in', width = 11, height = 7, res = 350)
upset(
  plot_data_wide, 
  intersect = colnames(tools_bin),
  name = 'Tools',
  set_sizes=(
    upset_set_size() + ylab('Total transcripts')),
  base_annotations = list(
    'Intersection size' = intersection_size(
      counts = TRUE,
      mapping = aes(fill = Type),
      text = list(angle = 90, hjust=-0.2, vjust=0.4, color="black")
    ) + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),axis.ticks.y = element_line(),axis.text.y = element_text(size = 14))
    )
  )
dev.off()

#Calculate how many novel shared for the highest intersection
all_tools <- tracking[,5:10]
all_tools %>%
  filter(
    FLAMES == "-",
    FLAIR == "-",
    RGT_Planet == "-",
    StringTie3 != "-",
    IsoQuant != "-",
    Bambu != "-"
  ) %>% nrow()
#Returns 784

############

##De novo
tracking <- read.table("denovo-gffcmp.tracking", header = FALSE, sep="\t", stringsAsFactors = FALSE)
colnames(tracking) <- c("frag_id","locus","ref-gene-id","class-code","Bambu","IsoQuant","StringTie3", "RGT_Planet")
tools <- tracking[,5:7]

tools_bin <- as.data.frame(lapply(tools, function(x) ifelse(x == "-", 0, 1))) #make it binary
rownames(tools_bin) <- sub("\\|.*", "", tracking$frag_id) #use the fragment id


plot_data <- do.call(rbind, lapply(names(tools_bin), function(tool){
  genes <- rownames(tools_bin)[tools_bin[[tool]] == 1]
  data.frame(
    Gene = genes,
    Tool = tool,
    Reference_support = ifelse(tracking$RGT_Planet[match(genes, sub("\\|.*", "", tracking$frag_id))] == "-", 
                  "Unsupported", "Supported")
  )
})) #if the RGT Planet column is - then it is unsupported 

#Make the data wide
plot_data_wide <- plot_data %>%
  mutate(Present = 1) %>%
  pivot_wider(names_from = Tool, values_from = Present, values_fill = 0)

#Plot
png(filename = "denovo-upset-plot.png", units = 'in', width = 11, height = 7, res = 350)
upset(
  plot_data_wide, 
  intersect = colnames(tools_bin),
  name = 'Tools',
  set_sizes=(
    upset_set_size() + ylab('Total transcripts')),
  base_annotations = list(
    'Intersection size' = intersection_size(
      counts = TRUE,
      mapping = aes(fill = Reference_support),
      text = list(angle = 90, hjust=-0.2, vjust=0.4, color="black")
    ) + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.ticks.y = element_line(),axis.text.y = element_text(size = 14)) + labs(fill = "Reference support")
  ) 
)
dev.off()
