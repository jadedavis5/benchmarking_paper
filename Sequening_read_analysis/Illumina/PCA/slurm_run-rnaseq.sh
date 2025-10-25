#!/bin/bash -l

#SBATCH --job-name=rnaseq
#SBATCH --account=fl3
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=10:00:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --export=ALL
#SBATCH --mem=10GB

module load singularity/4.1.0-slurm
module load nextflow/24.10.0


#git clone --branch 3.18.0 https://github.com/nf-core/rnaseq

#update rnaseq/modules/nf-core/cat/fastq/main.nf with "container 'quay.io/nf-core/coreutils:9.5--ae99c88a9b28c264'"
#update rnaseq/modules/nf-core/bedtools/genomecov/main.nf with "container 'quay.io/nf-core/bedtools_coreutils:a623c13f66d5262b'"
#In conf/base.config also changed medium_process label to 80Gb so salmon won't run out of mem

gtf=/scratch/fl3/jdavis/reference_files/RGT_Planet_v2.gtf
genome=/scratch/fl3/jdavis/reference_files/220816_RGT_Planet_pseudomolecules_and_unplaced_contigs_CPclean.fasta


nextflow run rnaseq/main.nf \
--input samplesheet.csv \
--outdir output --bam_csi_index \
--gtf $gtf \
--aligner star_rsem \
--fasta $genome \
-profile pawsey_setonix,singularity -resume
