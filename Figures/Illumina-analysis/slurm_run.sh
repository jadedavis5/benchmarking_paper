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
module load nextflow/24.04.3

#Take out unstranded annotations
gff=/scratch/fl3/jdavis/final_annotations/final_results/annotations/outputAnnotation_STref.gff
awk -F'\t' '$7 != "."' $gff > outputAnnotation_STref_strandedFilter.gff

#git clone https://github.com/nf-core/rnaseq # nf-core/rnaseq v3.18.0

#In rnaseq/modules/nf-core/cat/fastq/main.nf changed "container 'nf-core/coreutils:9.5--ae99c88a9b28c264'" to "container 'quay.io/nf-core/coreutils:9.5--ae99c88a9b28c264'"
#In to modules/nf-core/bedtools/genomecov/main.nf changed 'container 'nf-core/bedtools_coreutils:a623c13f66d5262b''to 'container 'quay.io/nf-core/bedtools_coreutils:a623c13f66d5262b''
#In conf/base.config also changed medium_process label to 80Gb so salmon won't run out

nextflow run rnaseq/main.nf \
--input sampleSheet.csv \
--outdir output --bam_csi_index \
--gff outputAnnotation_STref_strandedFilter.gff \
--aligner star_rsem \
--fasta /scratch/fl3/jdavis/REFERENCES/RGT_2_2024/220816_RGT_Planet_pseudomolecules_and_unplaced_contigs_CPclean.fasta \
-profile pawsey_setonix,singularity -resume
