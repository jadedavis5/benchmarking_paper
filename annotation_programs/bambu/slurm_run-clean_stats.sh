#!/bin/bash -l

#SBATCH --job-name=run-pipeline
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

module load nextflow/23.10.0

module load singularity/4.1.0-nompi

for file in outputAnnotation_UNCLEAN_BAMBUnoref.gtf outputAnnotation_UNCLEAN_BAMBUref.gtf
do
nextflow run main.nf -profile pawsey_setonix,singularity --gtf_input $file --mode 'clean_stats' \
--genome '/scratch/fl3/jdavis/REFERENCES/RGT_2_2024/220816_RGT_Planet_pseudomolecules_and_unplaced_contigs_CPclean.fasta' --ref_annotation '/scratch/fl3/jdavis/REFERENCES/RGT_2_2024/RGT_Planet_v2.gtf'
done
