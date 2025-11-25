1. Run the NanoFLORA (https://github.com/jadedavis5/NanoFLORA) pipeline for read pre-processing and alignment
2. Take the sample to genome BAM files from the output/processing/minimap2/ directory
3. Look at your reference input GTF- if it has the transcript_id before the gene_id in the 9th field then use bambu-editGTF.sh to fix it. Bambu prefers this GTF formatting
5. Input BAM files and GTF into the bambu.R script for processing
6. Take the unclean output annotations and put them through the NanoFLORA clean-stats mode (slurm_run-clean_stats.sh)
