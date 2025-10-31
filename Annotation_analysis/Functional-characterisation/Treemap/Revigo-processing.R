library(dplyr)
library(stringr)
library(tidyr)
library(ggplot2)
#install.packages("treemap")
library(treemap)
library(data.table)
library(readr)
library(RColorBrewer)

#Turn the InterProScan TSV output file into input for Revigo (http://revigo.irb.hr/)

########## STRINGTIE3 ##########
ST_data <- fread("STref-novel_proteins.fa.csv", header = FALSE, sep = ",", fill = TRUE, quote="")
ST_data <- ST_data %>% select(-c(V2, V3))
ST_data$V8 <- lapply(ST_data$V8, as.character)

#Extract GO terms and put them into their own column 
ST_data <- ST_data %>%
  rowwise() %>%
  mutate(
    GO_terms = ifelse(length(na.omit(unlist(str_extract_all(c_across(everything()), "GO:\\S+")))) == 0, 
                      NA, 
                      paste(na.omit(unlist(str_extract_all(c_across(everything()), "GO:\\S+"))), collapse = ", "))
  ) %>%
  ungroup()

ST_data <- select(ST_data, V1, GO_terms)


#Clean GO terms including separators and () and extract into new columns 
ST_data <- ST_data %>%
  mutate(
    GO_terms_cleaned = str_replace_all(GO_terms, "\\(.*?\\)", ""),
    GO_terms_split = str_split(GO_terms_cleaned, "\\|"),
  ) %>%
  unnest_wider(GO_terms_split, names_sep = "_")

ST_data <- ST_data[, -c(2:3)] #take out uncleaned intermediate GO columns

#Take out rows where there are no GO terms in columns
ST_data <- ST_data[-which(is.na(ST_data$GO_terms_split_1)), ]


#Summarize to take out duplicate transcript name rows and collapse GO terms 
ST_data_summary <- ST_data %>%
  pivot_longer(cols = 2:ncol(ST_data), names_to = "GO_column", values_to = "GO_term") %>% 
  group_by(V1) %>% 
  summarise(
    GO_terms = str_c(unique(na.omit(GO_term)), collapse = ", ")
  ) %>%
  ungroup() %>%
  separate(GO_terms, into = paste0("GO_term_", seq(1, 10)), sep = ", ", fill = "right")

ST_go_count <- ST_data_summary %>%
  pivot_longer(cols = starts_with("GO_term"), 
               names_to = "GO_column", 
               values_to = "GO_term") %>%
  filter(!is.na(GO_term)) %>%
  count(GO_term, sort = TRUE) 

# View the result
write.table(ST_go_count, file='ST_go_count.tsv', sep='\t', row.names = FALSE, quote=FALSE)


########## ISOQUANT ##########
#Turn the InterProScan TSV output file into input for Revigo (http://revigo.irb.hr/)
IQ_data <- fread("IQref-novel_proteins.fa.csv", header = FALSE, sep = ",", fill = TRUE, quote="")
IQ_data <- IQ_data %>% select(-c(V2, V3))
IQ_data$V8 <- lapply(IQ_data$V8, as.character)

#Extract GO terms and put them into their own column 
IQ_data <- IQ_data %>%
  rowwise() %>%
  mutate(
    GO_terms = ifelse(length(na.omit(unlist(str_extract_all(c_across(everything()), "GO:\\S+")))) == 0, 
                      NA, 
                      paste(na.omit(unlist(str_extract_all(c_across(everything()), "GO:\\S+"))), collapse = ", "))
  ) %>%
  ungroup()

IQ_data <- select(IQ_data, V1, GO_terms)


#Clean GO terms including separators and () and extract into new columns 
IQ_data <- IQ_data %>%
  mutate(
    GO_terms_cleaned = str_replace_all(GO_terms, "\\(.*?\\)", ""),
    GO_terms_split = str_split(GO_terms_cleaned, "\\|"),
  ) %>%
  unnest_wider(GO_terms_split, names_sep = "_")

IQ_data <- IQ_data[, -c(2:3)] #take out uncleaned intermediate GO columns

#Take out rows where there are no GO terms in columns
IQ_data <- IQ_data[-which(is.na(IQ_data$GO_terms_split_1)), ]


#Summarize to take out duplicate transcript name rows and collapse GO terms 
IQ_data_summary <- IQ_data %>%
  pivot_longer(cols = 2:ncol(IQ_data), names_to = "GO_column", values_to = "GO_term") %>% 
  group_by(V1) %>% 
  summarise(
    GO_terms = str_c(unique(na.omit(GO_term)), collapse = ", ")
  ) %>%
  ungroup() %>%
  separate(GO_terms, into = paste0("GO_term_", seq(1, 10)), sep = ", ", fill = "right")

IQ_go_count <- IQ_data_summary %>%
  pivot_longer(cols = starts_with("GO_term"), 
               names_to = "GO_column", 
               values_to = "GO_term") %>%
  filter(!is.na(GO_term)) %>%
  count(GO_term, sort = TRUE) 


write.table(IQ_go_count, file='IQ_go_count.tsv', sep='\t', row.names = FALSE, quote=FALSE)

#Also make a combined one so we can assign a distinct colour for each group
combined <- bind_rows(IQ_go_count, ST_go_count) %>%
  group_by(GO_term) %>%
  summarise(n = sum(n))
write.table(combined, file='combined_go_count.tsv', sep='\t', row.names = FALSE, quote=FALSE)

################### Take the go_counts.tsv file, put it into Revigo, download the TSV output and use this script to create a nicer looking plot ###################
ST_tree <- read_tsv("ST_Revigo_BP_TreeMap.tsv", comment = "#")
IQ_tree <- read_tsv("IQ_Revigo_BP_TreeMap.tsv", comment = "#")
all_tree <- read_tsv("combined_Revigo_BP_TreeMap.tsv", comment = "#")

all_tree$Representative[all_tree$Representative == "null"] <- all_tree$Name[all_tree$Representative == "null"]

ST_tree$Group <- all_tree$Representative[match(ST_tree$Name, all_tree$Name)]
IQ_tree$Group <- all_tree$Representative[match(IQ_tree$Name, all_tree$Name)]

#unique colour for each group
colours <- colorRampPalette(RColorBrewer::brewer.pal(8, "Set2"))(length(unique(all_tree$Representative)))
colour_groups <- setNames(colours, unique(all_tree$Representative))

ST_tree$Colour <- colour_groups[ST_tree$Group]
IQ_tree$Colour <- colour_groups[IQ_tree$Group]

png("ST_treemap_colourFix.png", width = 2400, height = 1800)
treemap(ST_tree,
              index = c("Group", "Name"),
              vSize = "Value",
              draw = TRUE,
              title = "Treemap of GO Terms",
              vColor = "Colour",
              type =  "color",
              border.col = "white",
              position.legend = "none",
              fontsize.labels = c(0, 50),
              border.lwds = 5,
              hide.index = TRUE,
              aspRatio = 2,
              align.labels = c("center","center"))
dev.off()

png("IQ_treemap_colourFix.png", width = 2400, height = 1800)
treemap(IQ_tree,
        index = c("Group", "Name"),
        vSize = "Value",
        draw = TRUE,
        title = "Treemap of GO Terms",
        vColor = "Colour",
        type =  "color",
        border.col = "white",
        position.legend = "none",
        fontsize.labels = c(0, 50),
        border.lwds = 5,
        hide.index = TRUE,
        aspRatio = 2,
        align.labels = c("center","center"))
dev.off()
