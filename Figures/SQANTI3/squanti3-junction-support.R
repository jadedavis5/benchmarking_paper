library(tidyverse)
library(ggplot2)

file.copy("STref_junctions.txt", "StringTie2.ref_junctions.txt")
file.copy("STnoref_junctions.txt", "StringTie2.refFree_junctions.txt")

file.copy("IQref_junctions.txt", "IsoQuant.ref_junctions.txt")
file.copy("IQnoref_junctions.txt", "IsoQuant.refFree_junctions.txt")

file.copy("BAMBUref_junctions.txt", "BAMBU.ref_junctions.txt")
file.copy("BAMBUnoref_junctions.txt", "BAMBU.refFree_junctions.txt")

file.copy("FLAMESref_junctions.txt", "FLAMES.ref_junctions.txt")
file.copy("FLAIRref_junctions.txt", "FLAIR.ref_junctions.txt")


programs <- c("StringTie2.ref", "IsoQuant.ref","BAMBU.ref","FLAIR.ref","FLAMES.ref","StringTie2.refFree","IsoQuant.refFree","BAMBU.refFree")

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
                             round(100 * count / sum(count), 1), NA)) %>%
  ungroup()

#Plot
category_names <- c("Novel unsupported", "Novel supported")
category_order <- c("novel_unsupported", "novel_supported")
category_labels <- setNames(category_names, category_order) 

plot <- ggplot(plot_data, aes(x = Method, y = count, fill = category)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = ifelse(!is.na(percentage), paste0(percentage, "%"), "")), 
            position = position_stack(vjust = 0.5), size = 5) +
  labs(x = "Method", y = "Number of junctions", fill ="Junction type") +
  scale_fill_brewer(palette = "Dark2",labels = category_labels) +
  
  
  geom_segment(aes(x = 0.5, xend = 8.5, y = -500, yend = -500), color = "black") +  
  
  
  geom_segment(aes(x = 0.5, xend = 0.5, y = -1000, yend = 0), color = "black", size = 0.8) +  
  geom_segment(aes(x = 5.5, xend = 5.5, y = -1000, yend = 0), color = "black", size = 0.8) +
  geom_segment(aes(x = 8.5, xend = 8.5, y = -1000, yend = 0), color = "black", size = 0.8) +
  
  annotate("text", x = 3, y = -1000, label = "Reference guided", vjust = 0.5, size = 5) +
  annotate("text", x = 7, y = -1000, label = "De novo", vjust = 0.5, size = 5, fontface = 'italic') +
  theme_minimal() +
  theme(axis.text.x = element_text(angle=45, hjust = 1, size=13), 
        axis.text.y = element_text(size=13), 
        axis.title.y = element_text(face = "bold",size=15),
        axis.title.x = element_blank(),
        legend.text = element_text(size = 15),
        legend.title = element_text(size = 18)) 

plot
ggsave(filename = "junction-support.tiff", plot = plot, device = 'tiff', width= 10, height= 7.22, dpi = 500)

