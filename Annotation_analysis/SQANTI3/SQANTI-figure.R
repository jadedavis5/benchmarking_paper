#Revise SQANTI3 figure- stack plots on top of each other, remove gridlines
remove.packages(c("ggplot2", "patchwork"))
install.packages('ggplot2')
install.packages('patchwork')

library(tidyverse)
library(ggplot2)
library(patchwork)

######## Classifications plot ########

#Rename classification files for better plotting
# #Copy and rename files- easier than renaming categories after making variables 
# #file.copy("STref_classification.txt", "StringTie3.ref_classification.txt")
# #file.copy("STnoref_classification.txt", "StringTie3.refFree_classification.txt")
# 
# #file.copy("IQref_classification.txt", "IsoQuant.ref_classification.txt")
# #file.copy("IQnoref_classification.txt", "IsoQuant.refFree_classification.txt")
# 
# #file.copy("BAMBUref_classification.txt", "Bambu.ref_classification.txt")
# #file.copy("BAMBUnoref_classification.txt", "Bambu.refFree_classification.txt")
# 
# #file.copy("FLAMESref_classification.txt", "FLAMES.ref_classification.txt")
# #file.copy("FLAIRref_classification.txt", "FLAIR.ref_classification.txt")

programs <- c("StringTie3.ref", "IsoQuant.ref","Bambu.ref","FLAIR.ref","FLAMES.ref","StringTie3.refFree","IsoQuant.refFree","Bambu.refFree")


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
class_data_combined <- bind_rows(data_list)
class_data_combined$Method <- factor(class_data_combined$Method, levels = programs)

unique(class_data_combined$Method)

#Create plot
class_category_names <- c("Full splice match", "Novel in catalog", "Novel not in catalog", #Create nicer names for legend
                    "Genic", "Intergenic", "Incomplete splice match", 
                    "Genic intron", "Antisense")
class_category_order <- c("full-splice_match", "novel_in_catalog", "novel_not_in_catalog", #Order categories
                    "genic", "intergenic", "incomplete-splice_match", 
                    "genic_intron", "antisense")
class_category_labels <- setNames(class_category_names, class_category_order) 


class_data_combined$structural_category <- factor(class_data_combined$structural_category, 
                                            levels = class_category_order)


classifications_plot <- ggplot(class_data_combined, aes(x = Method, fill = structural_category)) +
  
  geom_bar(position = "stack") +
  labs(x = "Method", y = "Transcript count", fill = "Structural category") +
  scale_x_discrete(labels = gsub("\\.(ref|refFree)", "", programs)) +
  scale_fill_brewer(palette = "Set2",limits = class_category_order,labels = class_category_labels) +
  theme_minimal() +
  theme(axis.text.x = element_blank(), 
        axis.text.y = element_text(size=16), 
        axis.title.y = element_text(face = "bold",size=18),
        axis.title.x = element_blank(),
        legend.text = element_text(size = 16),
        legend.title = element_text(size = 18),
        axis.ticks.x = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())
classifications_plot
######## Junctions plot ########

# file.copy("STref_junctions.txt", "StringTie3.ref_junctions.txt")
# file.copy("STnoref_junctions.txt", "StringTie3.refFree_junctions.txt")
# 
# file.copy("IQref_junctions.txt", "IsoQuant.ref_junctions.txt")
# file.copy("IQnoref_junctions.txt", "IsoQuant.refFree_junctions.txt")
# 
# file.copy("BAMBUref_junctions.txt", "Bambu.ref_junctions.txt")
# file.copy("BAMBUnoref_junctions.txt", "Bambu.refFree_junctions.txt")
# 
# file.copy("FLAMESref_junctions.txt", "FLAMES.ref_junctions.txt")
# file.copy("FLAIRref_junctions.txt", "FLAIR.ref_junctions.txt")

for (program in programs) {
  file_name <- paste0(program, "_junctions.txt")
  data <- read.delim(file_name)
  data$Method <- program
  assign(paste0(program, "_junctions"), data)
}

data_list <- lapply(programs, function(program) {
  data <- get(paste0(program, "_junctions"))
  data
})
data_combined <- bind_rows(data_list)
data_combined$Method <- factor(data_combined$Method, levels = programs)

plot_data <- data_combined %>%
  filter(junction_category == "novel") %>%
  group_by(Method) %>%
  summarise(novel_supported = sum(total_coverage_unique > 10), 
            novel_unsupported = sum(total_coverage_unique <= 10)) %>%
  pivot_longer(cols = c(novel_unsupported, novel_supported), 
               names_to = "category", values_to = "count") %>%
  group_by(Method) %>%
  mutate(percentage = ifelse(category == "novel_supported", 
                             round(100 * count / sum(count), 0), NA)) %>%
  ungroup()

#Plot
category_names <- c("Novel unsupported", "Novel supported")
category_order <- c("novel_unsupported", "novel_supported")
category_labels <- setNames(category_names, category_order) 

junctions_plot <- ggplot(plot_data, aes(x = Method, y = count, fill = category)) +
  scale_x_discrete(labels = gsub("\\.(ref|refFree)", "", programs)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = ifelse(!is.na(percentage), paste0(percentage, "%"), "")), 
            position = position_stack(vjust = 0.5), size = 5) +
  labs(x = "Method", y = "Number of junctions", fill ="Junction type") +
  scale_fill_brewer(palette = "Set2",labels = category_labels) +
  expand_limits(y = 22000) +
  
  geom_segment(aes(x = 0.5, xend = 8.5, y = -500, yend = -500), color = "black") +  
  geom_segment(aes(x = 0.5, xend = 0.5, y = -1000, yend = 0), color = "black", size = 0.8) +  
  geom_segment(aes(x = 5.5, xend = 5.5, y = -1000, yend = 0), color = "black", size = 0.8) +
  geom_segment(aes(x = 8.5, xend = 8.5, y = -1000, yend = 0), color = "black", size = 0.8) +
  
  annotate("text", x = 3, y = -1000, label = "Reference guided", vjust = 0.5, size = 5.5) +
  annotate("text", x = 7, y = -1000, label = "De novo", vjust = 0.5, size = 5.5, fontface = 'italic') +
  theme_minimal() +
  theme(axis.text.x = element_text(angle=45, hjust = 1, size=16), 
        axis.text.y = element_text(size=16), 
        axis.title.y = element_text(face = "bold",size=18),
        axis.title.x = element_blank(),
        legend.text = element_text(size = 16),
        legend.title = element_text(size = 18),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) 

junctions_plot
#Look at FLAIR closer
library(dplyr)

flair_novel <- data_combined %>%
  filter(Method == "FLAIR.ref", junction_category == "novel")

print(flair_novel)

######## Stack plots ########

patchwork <- classifications_plot / junctions_plot
ggsave("SQANTI3-combined-figure.png", plot = patchwork, width = 10, height = 12, dpi = 600) 
