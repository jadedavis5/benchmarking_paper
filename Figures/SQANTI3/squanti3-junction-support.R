library(tidyverse)
library(ggplot2)

programs <- c("STref","STnoref","IQref","IQnoref","FLAIRref","BAMBUref","BAMBUnoref", "FLAMESref")


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
                             round(100 * count / sum(count), 2), NA)) %>%
  ungroup()

#Plot
category_names <- c("Novel unsupported", "Novel supported")
category_order <- c("novel_unsupported", "novel_supported")
category_labels <- setNames(category_names, category_order) 

ggplot(plot_data, aes(x = Method, y = count, fill = category)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = ifelse(!is.na(percentage), paste0(percentage, "%"), "")), 
            position = position_stack(vjust = 0.5), size = 5) +
  labs(x = "Method", y = "Number of junctions", fill ="Junction type") +
  scale_fill_brewer(palette = "Dark2",labels = category_labels) +
  theme_minimal() 
