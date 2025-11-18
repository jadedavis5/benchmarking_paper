#Plot ISM lengths vs RGT Planet transcript length 
library(ggplot2)
library(dplyr)

#Extract ref transcript lengths
ref_gtf <- read.table("RGT_Planet_v2.gtf", sep = "\t", header = FALSE)
ref_transcript_lengths <- ref_gtf$V5[ref_gtf$V3=="transcript"] - ref_gtf$V4[ref_gtf$V3=="transcript"]
ref_df <- data.frame(
  Method = "RGT.Planet",
  length = ref_transcript_lengths
)

#Extract lengths of ISMs from all annotations
programs <- c("StringTie3.ref", "IsoQuant.ref","Bambu.ref","FLAIR.ref","FLAMES.ref","StringTie3.refFree","IsoQuant.refFree","Bambu.refFree")

for (program in programs) {
  file_name <- paste0(program, "_classification.txt")
  data <- read.delim(file_name)
  data$Method <- program
  assign(paste0(program, "_classifications"), data)
}

all_classifications <- do.call(rbind, mget(paste0(programs, "_classifications")))
ism <- all_classifications[all_classifications$structural_category == "incomplete-splice_match" & all_classifications$subcategory == "3prime_fragment",]
#31,369 ISMs between all methods (rg and de novo)
#29,877 just 3' fragment (meaning 5' truncation)

#3' fragments for the following:
#"IsoQuant.ref"       "FLAIR.ref"          "FLAMES.ref"         "StringTie3.refFree" "IsoQuant.refFree"  "Bambu.refFree" 

#Bring datasets together for boxplot
labels1 <- c(
  "RGT.Planet"       = "RGT Planet",
  "IsoQuant.ref"     = "IsoQuant",
  "FLAIR.ref"        = "FLAIR",
  "FLAMES.ref"       = "FLAMES",
  "StringTie3.refFree" = "StringTie3",
  "IsoQuant.refFree"   = "IsoQuant",
  "Bambu.refFree"      = "Bambu"
)

all <- rbind(ism[, c("Method", "length")], ref_df)
levels_plot <- c("RGT.Planet", "IsoQuant.ref","FLAIR.ref","FLAMES.ref","StringTie3.refFree","IsoQuant.refFree","Bambu.refFree")
all$Method <- factor(all$Method, levels = levels_plot)


cols <- c(
  "Bambu.refFree"      = "#66C2A5",
  "FLAIR.ref"          = "#FC8D62",
  "FLAMES.ref"         = "#8DA0CB",
  "IsoQuant.ref"       = "#E78AC3",
  "StringTie3.refFree" = "#A6D854",
  "RGT.Planet"         = "#FFD92F",
  "IsoQuant.refFree"   = "#E78AC3"
)

p <- ggplot(all, aes(x = Method, y = length, fill = Method)) +
  scale_x_discrete(labels = labels1) +
  geom_boxplot(outlier.size = 0.5) +
  labs(y = "Transcript length (bp)") +
  theme_minimal() +
  scale_fill_manual(values = cols) +
  theme(legend.position = "none",
        axis.text.x = element_text(angle=45, hjust = 1, size=16),
        axis.title.x = element_blank(),
        axis.title.y = element_text(face = "bold",size=18),
        axis.text.y = element_text(size=16), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  coord_cartesian(ylim = c(0, 10000))

  
final_plot <- p + geom_segment(aes(x = 1.5, xend = 4.5, y = 0, yend = 0), color = "black", size = 0.8) +
  geom_segment(aes(x = 4.5, xend = 7.5, y = 0, yend = 0), color = "black", size = 0.8) +
  
  geom_segment(aes(x = 1.5, xend = 1.5, y = 200, yend = -200), color = "black", size = 0.8) +
  geom_segment(aes(x = 4.5, xend = 4.5, y = 200, yend = -200), color = "black", size = 0.8) +
  geom_segment(aes(x = 7.5, xend = 7.5, y = 200, yend = -200), color = "black", size = 0.8) +
  
  annotate("text", x = 3, y = -200, label = "Reference guided", size = 6) +
  annotate("text", x = 6, y = -200, label = "De novo", size = 6, fontface = "italic")
ggsave(filename = "ISM-boxplot.tiff", plot = final_plot, device = 'tiff', width= 10, height= 7.22, dpi = 500)
