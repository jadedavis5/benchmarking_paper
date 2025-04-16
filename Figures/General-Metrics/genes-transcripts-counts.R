#Genes and transcripts plot

library(ggplot2)
library(reshape2)

data <- read.csv("genes_transcripts.csv", row.names = 1)
data_t <- t(data)
data_long <- melt(data_t, id.vars = rownames(data_t))

desired_order <- c("RGT.Planet", "StringTie2.ref",	"IsoQuant.ref",	"Bambu.ref","FLAIR.ref", "FLAMES.ref","StringTie2.refFree",	"IsoQuant.refFree",	"Bambu.refFree") 


colnames(data_long) <- c("Method", "Category", "Value")
data_long$Method <- factor(data_long$Method, levels = desired_order)


plot <- ggplot(data_long, aes(x = Method, y = Value, fill = Category)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_x_discrete(labels = gsub("\\.(ref|refFree)", "", desired_order)) +
  labs(y = "Count", ,
       x = "Method") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size=10), axis.text.y = element_text(size = 10),
        axis.title.y = element_text(face = "bold",size=15),
        axis.title.x = element_text(face = "bold",size=15),
        legend.text = element_text(size = 15),
        legend.title = element_text(size = 18)) +
  
  
  geom_segment(aes(x = 1.5, xend = 6.5, y = -2000, yend = -2000), color = "black") +  
  geom_segment(aes(x = 6.5, xend = 9.5, y = -2000, yend = -2000), color = "black") +  
  
  
  geom_segment(aes(x = 1.5, xend = 1.5, y = -5000, yend = 0), color = "black", size = 0.8) +  #short line for reference guided
  geom_segment(aes(x = 6.5, xend = 6.5, y = -5000, yend = 0), color = "black", size = 0.8) +  #short line for de novo
  geom_segment(aes(x = 9.5, xend = 9.5, y = -5000, yend = 0), color = "black", size = 0.8) +
  
  annotate("text", x = 4, y = -4000, label = "Reference guided", vjust = 0.5, size = 5) +
  annotate("text", x = 8, y = -4000, label = "De novo", vjust = 0.5, size = 5, fontface = 'italic') +
  ylim(-5000, max(data_long$Value))
plot
ggsave(filename = "genes-transcripts-counts.tiff", plot = plot, device = 'tiff', width= 7.66, height= 7.22, dpi = 500)

