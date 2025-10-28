remove.packages("ComplexUpset")
install.packages("ComplexUpset", type = "source")
library(ComplexUpset)
library(ggplot2)
library(reshape2)
library(tidyr)
library(dplyr)
library(patchwork)


######## Ref guided ########
tracking <- read.table("refguided-gffcmp.tracking", header = FALSE, sep="\t", stringsAsFactors = FALSE)
colnames(tracking) <- c("frag_id","locus","ref-gene-id","class-code","FLAMES","Bambu","FLAIR","IsoQuant","StringTie3", "RGT_Planet")
tools <- tracking[,5:9]
tools_bin <- as.data.frame(lapply(tools, function(x) ifelse(x == "-", 0, 1))) #make it binary
rownames(tools_bin) <- sub("\\|.*", "", tracking$frag_id) #use the fragment id


rg_plot_data <- do.call(rbind, lapply(names(tools_bin), function(tool){
  genes <- rownames(tools_bin)[tools_bin[[tool]] == 1]
  data.frame(
    Gene = genes,
    Tool = tool,
    Type = ifelse(tracking$RGT_Planet[match(genes, sub("\\|.*", "", tracking$frag_id))] == "-", 
                  "Novel", "Known")
  )
})) #if the RGT Planet column is - then it is Novel 

#Make the data wide
rg_plot_data_wide <- rg_plot_data %>%
  mutate(Present = 1) %>%
  pivot_wider(names_from = Tool, values_from = Present, values_fill = 0)

#Plot
rg_upset_plot <- upset(
  rg_plot_data_wide, 
  intersect = colnames(tools_bin),
  name = 'Tools',
  set_sizes=upset_set_size() +
    ylab('Total transcripts'),
  base_annotations = list(
    'Intersection size' = intersection_size(
      counts = TRUE,
      mapping = aes(fill = Type),
      text = list(angle = 90, hjust=0, vjust=0.4, color="black")
     ) + theme(panel.grid.major = element_blank(), 
               panel.grid.minor = element_blank(),
               axis.ticks.y = element_line(),
               axis.text.y = element_text(size = 16),
               axis.title.y = element_text(face = "bold",size=17),
               axis.title.x = element_blank()) + scale_fill_brewer(palette = "Set2")
    )
  )
rg_upset_plot

#Calculate how many novel shared for the highest intersection
all_tools_intersect <- tracking[,5:10]
# all_tools_intersect %>%
#   filter(
#     FLAMES == "-",
#     FLAIR == "-",
#     RGT_Planet == "-",
#     StringTie3 != "-",
#     IsoQuant != "-",
#     Bambu != "-"
#   ) %>% nrow()
#Returns 784

#Calculate how many FLAIR + how many are novel
all_tools_intersect %>%
     filter(
       FLAMES == "-",
       FLAIR != "-",
       RGT_Planet != "-",
       StringTie3 == "-",
       IsoQuant == "-",
       Bambu == "-"
     ) %>% nrow()



######## De novo ########

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
dn_upset_plot <- upset(
  plot_data_wide, 
  intersect = colnames(tools_bin),
  name = 'Tools',
  set_sizes=(
    upset_set_size() + ylab('Total transcripts')),
  base_annotations = list(
    'Intersection size' = intersection_size(
      counts = TRUE,
      mapping = aes(fill = Reference_support),
      text = list(angle = 90, hjust=0, vjust=0.4, color="black")
    ) + theme(panel.grid.major = element_blank(), 
              panel.grid.minor = element_blank(), 
              axis.ticks.y = element_line(),
              axis.text.y = element_text(size = 16), 
              axis.title.y = element_text(face = "bold",size=17),
              axis.title.x = element_blank()) + labs(fill = "Reference support") + scale_fill_brewer(palette = "Set2")
  ) 
)


#Calculate how many unique Bambu are supported 
# all_tools_bambu <- tracking[,5:8]
# all_tools_bambu %>%
#   filter(
#     RGT_Planet != "-",
#     StringTie3 == "-",
#     IsoQuant == "-",
#     Bambu != "-"
#   ) %>% nrow()
#Returns 1428


######## Stack plots ########
dev.off()
library(cowplot) #use cowplot instead of patchwork so that both plots retain all points

combined <- plot_grid(rg_upset_plot, dn_upset_plot, ncol = 1, align = "v", rel_heights = c(1,1))
ggsave("upset-combined-figure.png", plot = combined, width = 10, height = 12, dpi = 600)
