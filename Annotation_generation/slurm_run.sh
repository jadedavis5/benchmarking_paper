#!/bin/bash -l

#SBATCH --job-name=pipeline
#SBATCH --account=fl3
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --export=ALL
#SBATCH --mem=15GB

module load nextflow/24.10.0

module load singularity/4.1.0-nompi

genome=/scratch/fl3/jdavis/reference_files/220816_RGT_Planet_pseudomolecules_and_unplaced_contigs_CPclean.fasta
gtf=/scratch/fl3/jdavis/reference_files/RGT_Planet_v2.gtf


####
#IsoQuant rg
#nextflow run main.nf -profile pawsey_setonix,singularity --nanopore_reads '/scratch/fl3/jdavis/raw_nanopore_reads/manuscript/*.gz' \
#--genome $genome --ref_annotation $gtf --out IQref -resume

#IsoQuant de novo
nextflow run main.nf -profile pawsey_setonix,singularity --nanopore_reads '/scratch/fl3/jdavis/raw_nanopore_reads/manuscript/*.gz' \
--genome $genome --out IQnoref -resume
####

####
#St3 rg
#nextflow run main.nf -profile pawsey_setonix,singularity --nanopore_reads '/scratch/fl3/jdavis/raw_nanopore_reads/manuscript/*.gz' --tool 'ST' \
#--genome $genome --ref_annotation $gtf --out STref -resume

#St3 de novo 
#nextflow run main.nf -profile pawsey_setonix,singularity --nanopore_reads '/scratch/fl3/jdavis/raw_nanopore_reads/manuscript/*.gz' --tool 'ST' \
#--genome $genome --out STnoref -resume
####

####
#Bambu rg
#nextflow run main.nf -profile pawsey_setonix,singularity --nanopore_reads '/scratch/fl3/jdavis/raw_nanopore_reads/manuscript/*.gz' --tool 'BAMBU' \
#--genome $genome --ref_annotation $gtf --out BAMBUref -resume

#Bambu de novo
#nextflow run main.nf -profile pawsey_setonix,singularity --nanopore_reads '/scratch/fl3/jdavis/raw_nanopore_reads/manuscript/*.gz' --tool 'BAMBU' \
#--genome $genome --out BAMBUref -resume
####

#FLAIR rg
nextflow run main.nf -profile pawsey_setonix,singularity --nanopore_reads '/scratch/fl3/jdavis/raw_nanopore_reads/manuscript/*.gz' --tool 'FLAIR' \
--genome $genome --ref_annotation $gtf --out FLAIRref -resume

#FLAMES rg
#nextflow run main.nf -profile pawsey_setonix,singularity --nanopore_reads '/scratch/fl3/jdavis/raw_nanopore_reads/manuscript/*.gz' --tool 'FLAMES' \
#--genome $genome --ref_annotation $gtf --out FLAMESref -resume

