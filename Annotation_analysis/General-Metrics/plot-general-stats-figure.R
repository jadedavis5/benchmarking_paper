#Make a combined patchwork plot of general annotation statistics 
#install.packages("rcartocolor")
library(rcartocolor)
library(ggplot2)
library(reshape2)
library(RColorBrewer)
library(patchwork)
library(ggrepel)


desired_order <- c("RGT.Planet", "StringTie3.ref",	"IsoQuant.ref",	"Bambu.ref","FLAIR.ref", "FLAMES.ref","StringTie3.refFree",	"IsoQuant.refFree",	"Bambu.refFree") 

######## Gene/transcript counts ########

gt_data <- read.csv("genes_transcripts.csv", row.names = 1)
gt_data_t <- t(gt_data)
gt_data_long <- melt(gt_data_t, id.vars = rownames(gt_data_t))


colnames(gt_data_long) <- c("Method", "Category", "Value")
gt_data_long$Method <- factor(gt_data_long$Method, levels = desired_order)


gt_plot <- ggplot(gt_data_long, aes(x = Method, y = Value, fill = Category)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_x_discrete(labels = gsub("\\.(ref|refFree)", "", desired_order)) +
  labs(y = "Count",
       x = "Method") +
  scale_fill_brewer(palette="Set2") +
  theme_minimal() +
  theme(axis.text.x = element_blank(), axis.text.y = element_text(size = 20),
        axis.title.y = element_text(face = "bold",size=20),
        axis.title.x = element_blank(),
        legend.text = element_text(size = 20),
        legend.title = element_text(size = 21),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  ylim(-5000, max(gt_data_long$Value))
gt_plot

######## Transcript splicing ########
splice_data <- read.csv("transcript_splicing.csv", header = TRUE, row.names = 1)
splice_data_t <- t(splice_data)

splice_data_t <- as.data.frame(splice_data_t)
splice_data_t$Method <- rownames(splice_data_t)

splice_data_long <- melt(splice_data_t, id.vars = "Method", 
                  variable.name = "Category", 
                  value.name = "Percentage")

splice_data_long$Method <- factor(splice_data_long$Method, levels = desired_order)


splice_plot <- ggplot(splice_data_long, aes(x = Method, y = Percentage, fill = Category)) +
  geom_bar(stat = "identity") +
  labs(fill= "Splicing",
    x = "Method", 
    y = "Total transcripts (%)") +
  scale_fill_brewer(palette="Set2") +  
  scale_x_discrete(labels = gsub("\\.(ref|refFree)", "", desired_order)) +
  theme_minimal() +
  theme(axis.text.x = element_blank(), 
        axis.text.y = element_text(size = 20), 
        axis.title.x = element_blank(),  
        axis.title.y = element_text(face = "bold",size = 20),
        legend.text = element_text(size = 20),
        legend.title = element_text(size = 21),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())
splice_plot

######## Coding potential ########
code_data <- read.csv("coding_percentage.csv", header = TRUE, row.names = 1)
code_data_t <- t(code_data)

code_data_t <- as.data.frame(code_data_t)
code_data_t$Method <- rownames(code_data_t)
code_data_long <- melt(code_data_t, id.vars = "Method", 
                  variable.name = "Category", 
                  value.name = "Percentage")

code_data_long$Method <- factor(code_data_long$Method, levels = desired_order)


code_plot <- ggplot(code_data_long, aes(x = Method, y = Percentage, fill = Category)) +
  geom_bar(stat = "identity") +
  scale_x_discrete(labels = gsub("\\.(ref|refFree)", "", desired_order)) +
  labs(fill= "Coding potential",
    y = "Total transcripts (%)",
    x = "Method") +
  scale_fill_brewer(palette="Set2") +  
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 50, hjust = 1, size=20), 
        axis.title.y = element_text(face = "bold",size=20),
        axis.title.x = element_blank(),
        axis.text.y = element_text(size = 20),
        legend.text = element_text(size = 20),
        legend.title = element_text(size = 21),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  
  geom_segment(aes(x = 1.5, xend = 4.5, y = -5, yend = -5), color = "black") +
  geom_segment(aes(x = 4.5, xend = 9.5, y = -5, yend = -5), color = "black") +
  geom_segment(aes(x = 1.5, xend = 1.5, y = -10, yend = 0), color = "black", size = 0.5) + 
  geom_segment(aes(x = 6.5, xend = 6.5, y = -10, yend = 0), color = "black", size = 0.5) + 
  geom_segment(aes(x = 9.5, xend = 9.5, y = -10, yend = 0), color = "black", size = 0.5) +
  #Make category names bigger
  annotate("text", x = 4, y = -12, label = "Reference guided", vjust = 0.5, size = 8) +
  annotate("text", x = 8, y = -12, label = "italic('De novo')", vjust = 0.5, size = 8, parse =TRUE) + expand_limits(y = -15)
code_plot

######## Sensitivity and precision ########
sp_data <- read.csv("sensitivity_precision.csv")

method_order <- c(
  "StringTie3-ref", "StringTie3-deNovo" ,"IsoQuant-ref",  "IsoQuant-deNovo" , 
  "Bambu-ref","Bambu-deNovo", "FLAIR-ref", "FLAMES-ref"
)


sp_data$Method <- factor(sp_data$Method, levels = method_order)

method_colors <- c(
  "Bambu-deNovo" = "blue", "IsoQuant-deNovo" = "green", "StringTie3-deNovo" = "red",
  "Bambu-ref" = "blue", "IsoQuant-ref" = "green", "StringTie3-ref" = "red",
  "FLAIR-ref" = "purple", "FLAMES-ref" = "orange"
)

method_shapes <- c(
  "Bambu-deNovo" = 17, "IsoQuant-deNovo" = 17, "StringTie3-deNovo" = 17,
  "Bambu-ref" = 16, "IsoQuant-ref" = 16, "StringTie3-ref" = 16,
  "FLAIR-ref" = 16, "FLAMES-ref" = 16
)


sp_plot <- ggplot(sp_data, aes(x = Precision, y = Sensitivity, color = Method, shape = Method)) +
  geom_point(size = 7, alpha = 0.8) + 
  labs(
    x = "Precision (%)",
    y = "Sensitivity (%)",
    color = "Method",
    shape = "Method"
  ) +
  xlim(0, 100) + 
  ylim(0, 100) + 
  scale_color_manual(values = method_colors) + 
  scale_shape_manual(values = method_shapes) + 
  theme_minimal() + 
  theme(
    axis.text.x = element_text(size = 20),
    axis.text.y = element_text(size = 20),
    axis.title.x = element_text(size = 20, face = "bold"),
    axis.title.y = element_text(size = 20, face = "bold"),
    plot.title = element_blank(),
    legend.title = element_blank(),
    legend.text = element_text(size = 15),
    plot.margin = margin(1, 6, 1, 1, "cm"),
    legend.position = "bottom", 
    legend.justification = "center",
    legend.spacing.x = unit(0.8, 'cm')
  ) +
  guides(
    color = guide_legend(ncol = 6), 
    shape = guide_legend(nrow = 2, byrow = TRUE)
  )
sp_plot
ggsave("sp-plot.png", plot = sp_plot, width = 10, height = 10, dpi = 600)

######## Stack plots ########

plots <- (gt_plot / splice_plot / code_plot)

ggsave("stacked_plots.png", plot = plots, width = 10, height = 10, dpi = 600)
