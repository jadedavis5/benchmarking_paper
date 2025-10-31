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

genome=/scratch/fl3/jdavis/reference_files/220816_RGT_Planet_pseudomolecules_and_unplaced_contigs_CPclean.fasta

for annotation in STref IQref
do
        gff=/scratch/fl3/jdavis/manuscript/functional-analysis-ST-IQ/annotations/outputAnnotation_${annotation}.gff3

        #get rid of unstranded annotations-small issue for StringTie3
        awk -F'\t' '$7 != "."' $gff > outputAnnotation_${annotation}_strandedFilter.gff

        nextflow run rnaseq/main.nf \
        --input samplesheet.csv \
        --outdir ${annotation}_output --bam_csi_index \
        --gff outputAnnotation_${annotation}_strandedFilter.gff \
        --aligner star_rsem \
        --fasta $genome \
        -profile pawsey_setonix,singularity -resume
done
