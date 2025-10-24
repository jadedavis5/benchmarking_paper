#Turn the InterProScan TSV output file into input for Revigo (http://revigo.irb.hr/)

library(dplyr)
library(stringr)
library(tidyr)
library(ggplot2)
#install.packages("treemap")
library(treemap)

data <- read.delim("STref-novel_proteins.fa.csv",header = FALSE, sep = "," )
data <- data %>% select(-c(V2, V3))
data$V8 <- lapply(data$V8, as.character)

#Extract GO terms and put them into their own column 
data <- data %>%
  rowwise() %>%
  mutate(
    GO_terms = ifelse(length(na.omit(unlist(str_extract_all(c_across(everything()), "GO:\\S+")))) == 0, 
                      NA, 
                      paste(na.omit(unlist(str_extract_all(c_across(everything()), "GO:\\S+"))), collapse = ", "))
  ) %>%
  ungroup()

data <- select(data, V1, GO_terms)


#Clean GO terms including separators and () and extract into new columns 
data <- data %>%
  mutate(
    GO_terms_cleaned = str_replace_all(GO_terms, "\\(.*?\\)", ""),
    GO_terms_split = str_split(GO_terms_cleaned, "\\|"),
  ) %>%
  unnest_wider(GO_terms_split, names_sep = "_")

data <- data[, -c(2:3)] #take out uncleaned intermediate GO columns

#Take out rows where there are no GO terms in columns
data <- data[-which(is.na(data$GO_terms_split_1)), ]

#Summarize to take out duplicate transcript name rows and collapse GO terms 
data_summary <- data %>%
  pivot_longer(cols = 2:10, names_to = "GO_column", values_to = "GO_term") %>% 
  group_by(V1) %>% 
  summarise(
    GO_terms = str_c(unique(na.omit(GO_term)), collapse = ", ")
  ) %>%
  ungroup() %>%
  separate(GO_terms, into = paste0("GO_term_", seq(1, 10)), sep = ", ", fill = "right")

go_count <- data_summary %>%
  pivot_longer(cols = starts_with("GO_term"), 
               names_to = "GO_column", 
               values_to = "GO_term") %>%
  filter(!is.na(GO_term)) %>%
  count(GO_term, sort = TRUE) 

# View the result
print(go_count)
write.table(go_count, file='go_count.tsv', sep='\t', row.names = FALSE, quote=FALSE)


################### Take the go_counts.tsv file, put it into Revigo, download the TSV output and use this script to create a nicer looking plot ###################

data <- read.table("Revigo_BP_TreeMap.tsv", header = TRUE,sep = "\t")


#Replace "null" with NA in the Representative column for accurate grouping
data$Representative[data$Representative == "null"] <- NA

data <- data %>%
  mutate(Group = ifelse(is.na(Representative), Name, Representative))
png("treemap.png", width = 2400, height = 1800)
treemap(data,
        index = c("Group", "Name"),
        vSize = "Value",
        vColor = "Group",
        type = "categorical",
        draw = TRUE,
        title = "Treemap of GO Terms",
        palette = "Set2",
        border.col = "white",
        position.legend = "none",
        fontsize.labels = c(0, 50),
        border.lwds = 5,
        hide.index = TRUE,
        aspRatio = 2,
        align.labels = c("center","center"))
dev.off()
