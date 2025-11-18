#Plot annotated transcript lengths vs RGT Planet 
library(ggplot2)
library(dplyr)
library(RColorBrewer)

#Read in lengths
files <- list.files('.', pattern="\\.g(f|t)f", full.names=TRUE)

get_length <- function(f) {
  x <- read.table(f, sep="\t", quote="", comment.char="#", stringsAsFactors=FALSE)
  x <- x[x$V3 == "transcript", ]
  data.frame(Method = basename(f), length = x$V5 - x$V4)
}

df <- do.call(rbind, lapply(files, get_length))

#Rename for plot
labels1 <- c(
  "RGT_Planet_v2.gtf"       = "RGT Planet",
  "outputAnnotation_IQref.gff3"     = "IsoQuant",
  "outputAnnotation_IQnoref.gff3"   = "IsoQuant",
  "outputAnnotation_FLAIRref.gff3"        = "FLAIR",
  "outputAnnotation_FLAMESref.gff3"       = "FLAMES",
  "outputAnnotation_STref.gff3" = "StringTie3",
  "outputAnnotation_STnoref.gff3" = "StringTie3",
  "outputAnnotation_BAMBUref.gff3"      = "Bambu",
  "outputAnnotation_BAMBUnoref.gff3"      = "Bambu"
)

levels_plot <- c(
  "RGT_Planet_v2.gtf", "outputAnnotation_STref.gff3", "outputAnnotation_IQref.gff3",
  "outputAnnotation_BAMBUref.gff3","outputAnnotation_FLAIRref.gff3",
  "outputAnnotation_FLAMESref.gff3","outputAnnotation_STnoref.gff3",
  "outputAnnotation_IQnoref.gff3","outputAnnotation_BAMBUnoref.gff3"
)
df$Method <- factor(df$Method, levels = levels_plot)

#Make label for each program + coordinate colours 
df$Program <- labels1[as.character(df$Method)]
df$Program <- factor(df$Program, levels = unique(df$Program))
program_colours <- setNames(brewer.pal(n = length(levels(df$Program)), name = "Set2"),
                           levels(df$Program))


#Plot 
p <- ggplot(df, aes(x = Method, y = length, fill = Program)) +
  geom_boxplot(outlier.size = 0.5) +
  scale_x_discrete(labels = labels1) +
  labs(y = "Transcript length (bp)") +
  theme_minimal() +
  scale_fill_manual(values = program_colours) +
  theme(legend.position = "none",
        axis.text.x = element_text(angle=45, hjust = 1, size=16),
        axis.title.x = element_blank(),
        axis.title.y = element_text(face = "bold",size=18),
        axis.text.y = element_text(size=16), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  coord_cartesian(ylim = c(0, 10000))

final_plot <- p + geom_segment(aes(x = 1.5, xend = 9.5, y = 0, yend = 0), color = "black", size = 0.8) +
  
  geom_segment(aes(x = 1.5, xend = 1.5, y = 200, yend = -200), color = "black", size = 0.8) +
  geom_segment(aes(x = 6.5, xend = 6.5, y = 200, yend = -200), color = "black", size = 0.8) +
  geom_segment(aes(x = 9.5, xend = 9.5, y = 200, yend = -200), color = "black", size = 0.8) +
  
  annotate("text", x = 4, y = -200, label = "Reference guided", size = 6) +
  annotate("text", x = 8, y = -200, label = "De novo", size = 6, fontface = "italic")

ggsave(filename = "lengths-boxplot.tiff", plot = final_plot, device = 'tiff', width= 10, height= 7.22, dpi = 500)



Bambu      FLAIR     FLAMES   IsoQuant StringTie3 RGT Planet 
"#66C2A5"  "#FC8D62"  "#8DA0CB"  "#E78AC3"  "#A6D854"  "#FFD92F"
