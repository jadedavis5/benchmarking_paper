#install.packages("tidyverse")
library(tidyverse)
library(ggplot2)

#Copy and rename files- easier than renaming categories after making variables 
file.copy("STref_classification.txt", "StringTie2.ref_classification.txt")
file.copy("STnoref_classification.txt", "StringTie2.refFree_classification.txt")

file.copy("IQref_classification.txt", "IsoQuant.ref_classification.txt")
file.copy("IQnoref_classification.txt", "IsoQuant.refFree_classification.txt")

file.copy("BAMBUref_classification.txt", "Bambu.ref_classification.txt")
file.copy("BAMBUnoref_classification.txt", "Bambu.refFree_classification.txt")

file.copy("FLAMESref_classification.txt", "FLAMES.ref_classification.txt")
file.copy("FLAIRref_classification.txt", "FLAIR.ref_classification.txt")


programs <- c("StringTie2.ref", "IsoQuant.ref","Bambu.ref","FLAIR.ref","FLAMES.ref","StringTie2.refFree","IsoQuant.refFree","Bambu.refFree")


for (program in programs) {
  file_name <- paste0(program, "_classification.txt")
  data <- read.delim(file_name)
  data$Method <- program
  assign(paste0(program, "_classifications"), data)
}

data_list <- lapply(programs, function(program) {
  data <- get(paste0(program, "_classifications"))
  data
})
data_combined <- bind_rows(data_list)
data_combined$Method <- factor(data_combined$Method, levels = programs)

unique(data_combined$Method)
###########################
#Create plot
category_names <- c("Full splice match", "Novel in catalog", "Novel not in catalog", #Create nicer names for legend
                    "Genic", "Intergenic", "Incomplete splice match", 
                    "Genic intron", "Antisense")
category_order <- c("full-splice_match", "novel_in_catalog", "novel_not_in_catalog", #Order categories
                    "genic", "intergenic", "incomplete-splice_match", 
                    "genic_intron", "antisense")
category_labels <- setNames(category_names, category_order) 


data_combined$structural_category <- factor(data_combined$structural_category, 
                                            levels = category_order)

plot <- ggplot(data_combined, aes(x = Method, fill = structural_category)) +
  
  geom_bar(position = "stack") +
  labs(x = "Method", y = "Transcript count", fill = "Structural Category") +
  scale_x_discrete(labels = gsub("\\.(ref|refFree)", "", programs)) +
  scale_fill_brewer(palette = "Set3",limits = category_order,labels = category_labels) +
  geom_segment(aes(x = 0.5, xend = 6.5, y = -2000, yend = -2000), color = "black") +  
  geom_segment(aes(x = 5.5, xend = 8.5, y = -2000, yend = -2000), color = "black") +  
  
  
  geom_segment(aes(x = 0.5, xend = 0.5, y = -5000, yend = 0), color = "black", size = 0.8) +  
  geom_segment(aes(x = 5.5, xend = 5.5, y = -5000, yend = 0), color = "black", size = 0.8) +
  geom_segment(aes(x = 8.5, xend = 8.5, y = -5000, yend = 0), color = "black", size = 0.8) +
  
  annotate("text", x = 3, y = -4000, label = "Reference guided", vjust = 0.5, size = 5) +
  annotate("text", x = 7, y = -4000, label = "De novo", vjust = 0.5, size = 5, fontface = 'italic') +
  theme_minimal() +
  theme(axis.text.x = element_text(angle=45, hjust = 1, size=13), 
        axis.text.y = element_text(size=13), 
        axis.title.y = element_text(face = "bold",size=15),
        axis.title.x = element_text(face = "bold",size=15),
        legend.text = element_text(size = 15),
        legend.title = element_text(size = 18)) 
plot
summary_table <- data_combined %>%
  count(Method, structural_category) %>%
  tidyr::pivot_wider(names_from = structural_category, values_from = n, values_fill = 0)

print(summary_table)

ggsave(filename = "read-class.tiff", plot = plot, device = 'tiff', width= 10, height= 7.22, dpi = 500)
