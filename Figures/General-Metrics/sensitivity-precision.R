#Sensitivity and precision plot
library(ggplot2)
#install.packages("ggrepel")
library(ggrepel)

data <- read.csv("sensitivity_precision.csv")

#method_order <- c(
# "StringTie2-ref", "IsoQuant-ref","Bambu-ref", "FLAIR-ref", "FLAMES-ref",
#  "Bambu-refFree", "IsoQuant-refFree", "StringTie2-refFree"
#)
method_order <- c(
  "StringTie2-ref", "StringTie2-deNovo" ,"IsoQuant-ref",  "IsoQuant-deNovo" , 
  "Bambu-ref","Bambu-deNovo", "FLAIR-ref", "FLAMES-ref"
)


data$Method <- factor(data$Method, levels = method_order)

method_colors <- c(
  "Bambu-deNovo" = "blue", "IsoQuant-deNovo" = "green", "StringTie2-deNovo" = "red",
  "Bambu-ref" = "blue", "IsoQuant-ref" = "green", "StringTie2-ref" = "red",
  "FLAIR-ref" = "purple", "FLAMES-ref" = "orange"
)
method_shapes <- c(
  "Bambu-deNovo" = 17, "IsoQuant-deNovo" = 17, "StringTie2-deNovo" = 17,
  "Bambu-ref" = 16, "IsoQuant-ref" = 16, "StringTie2-ref" = 16,
  "FLAIR-ref" = 16, "FLAMES-ref" = 16
)


plot <- ggplot(data, aes(x = Precision, y = Sensitivity, color = Method, shape = Method)) +
  geom_point(size = 5.3, alpha = 0.8) + 
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
    axis.text.x = element_text(size = 16,face = "bold"),
    axis.text.y = element_text(size = 16,face = "bold"),
    axis.title.x = element_text(size = 16, face = "bold"),
    axis.title.y = element_text(size = 16, face = "bold"),
    plot.title = element_text(size = 14, face = "bold"),
    legend.title = element_text(size = 14,face = "bold"),
    legend.text = element_text(size = 12),
    plot.margin = margin(1, 6, 1, 1, "cm"),
    legend.position = "bottom", 
    legend.justification = "center",
    legend.spacing.x = unit(0.8, 'cm')
  ) +
  guides(
    color = guide_legend(ncol = 6), 
    shape = guide_legend(nrow = 2, byrow = TRUE)
  )
print(plot)
#print(plot + theme(panel.background = element_rect(fill = '#d4f3b7', colour = 'black'), plot.background = element_rect(fill = "transparent")))

ggsave(filename = "sensitivty-precision.tiff", plot = plot, device = 'tiff', width= 9, height= 6.17, dpi = 350)


