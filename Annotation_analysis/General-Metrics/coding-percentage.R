#Coding percentage plot

library(ggplot2)
library(reshape2)
library(RColorBrewer)

data <- read.csv("coding_percentage.csv", header = TRUE, row.names = 1)
data_t <- t(data)

data_t <- as.data.frame(data_t)
data_t$Method <- rownames(data_t)
data_long <- melt(data_t, id.vars = "Method", 
                  variable.name = "Category", 
                  value.name = "Percentage")


desired_order <- c("RGT.Planet", "StringTie2.ref",	"IsoQuant.ref",	"Bambu.ref", "FLAIR.ref","FLAMES.ref","StringTie2.deNovo",	"IsoQuant.deNovo",	"Bambu.deNovo") 

data_long$Method <- factor(data_long$Method, levels = desired_order)


palette <- brewer.pal(n = 3, name = "Set2")  

p <- ggplot(data_long, aes(x = Method, y = Percentage, fill = Category)) +
  geom_bar(stat = "identity") +
  scale_x_discrete(labels = gsub("\\.(ref|deNovo)", "", desired_order)) +
  labs( 
    y = "Percentage of total transcripts",
    x = "Method") +
  scale_fill_manual(values = palette) +  
  theme_minimal() +
  theme(axis.text.x = element_text(angle=45, hjust = 1, size=10), 
        axis.text.y = element_text(size=10), 
        axis.title.y = element_text(face = "bold",size=15),
        axis.title.x = element_text(face = "bold",size=15),
        legend.text = element_text(size = 15),
        legend.title = element_text(size = 18)) + 
  
  geom_segment(aes(x = 1.5, xend = 4.5, y = -5, yend = -5), color = "black") +
  geom_segment(aes(x = 4.5, xend = 9.5, y = -5, yend = -5), color = "black") +
  
  
  
  geom_segment(aes(x = 1.5, xend = 1.5, y = -10, yend = 0), color = "black", size = 0.5) + 
  geom_segment(aes(x = 6.5, xend = 6.5, y = -10, yend = 0), color = "black", size = 0.5) + 
  geom_segment(aes(x = 9.5, xend = 9.5, y = -10, yend = 0), color = "black", size = 0.5) +
  #Make category names bigger
  theme(axis.text.x = element_text(size = 12, angle = 45, hjust = 1)) +
  annotate("text", x = 4, y = -8, label = "Reference guided", vjust = 0.5, size = 5) +
  annotate("text", x = 8, y = -8, label = expression(italic("De novo")), vjust = 0.5, size = 5)
p
ggsave(filename = "coding.tiff", plot = p, device = 'tiff', width= 6.08, height= 5.71, dpi = 500)
