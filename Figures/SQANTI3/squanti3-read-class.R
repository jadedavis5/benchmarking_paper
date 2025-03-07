#install.packages("tidyverse")
library(tidyverse)
library(ggplot2)

programs <- c("STref","IQref","BAMBUref",  "FLAMESref", "FLAIRref","STnoref","IQnoref","BAMBUnoref")

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

ggplot(data_combined, aes(x = Method, fill = structural_category)) +
  geom_bar(position = "stack") +
  labs(x = "Method", y = "Transcript count", fill = "Structural Category") +
  scale_fill_brewer(palette = "Set3",limits = category_order,labels = category_labels) +
  theme_minimal()
