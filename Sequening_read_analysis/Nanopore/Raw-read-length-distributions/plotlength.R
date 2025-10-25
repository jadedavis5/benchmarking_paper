#Plot the length distribution of raw nanopore reads

library(ggplot2)

NB29 <- read.table("rna_010_ptt_f32_NB29_A_LENGTHS.txt")
control <- read.table("rna_011_ptt_f32_control_LENGTHS.txt")


NB29_df <- data.frame(length = NB29$V8, sample = "NFNB-infected")
control_df <- data.frame(length = control$V8, sample = "Control")

data <- rbind(NB29_df, control_df)

dev.off()
plot <- ggplot(data, aes(x = length, fill = sample)) +
  geom_histogram(binwidth = 1, alpha = 1) +
  xlim(0, 3500) + 
  labs(x = "Read length (bp)", y = "Number of reads", fill = "Sample") +
  facet_wrap(~sample, ncol = 1) + theme_minimal() +
  theme(legend.position = "none", 
        strip.text = element_text(face = "bold", size =16),
        axis.text.x = element_text(size =12), 
        axis.text.y = element_text(size = 12), 
        axis.title.x = element_text(face = "bold",size = 14),  
        axis.title.y = element_text(face = "bold",size = 14),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank())
print(plot)
ggsave(filename = "raw-readlength-distribution.tiff", plot = plot, device = 'tiff', dpi = 350)
