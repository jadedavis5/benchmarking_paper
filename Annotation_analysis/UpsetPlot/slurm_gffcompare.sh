#!/bin/bash -l

#SBATCH --job-name=gffcompare
#SBATCH --account=fl3
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --time=10:00:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --export=ALL
#SBATCH --mem=5GB


module load singularity/4.1.0-slurm
gffcompare=/software/projects/fl3/jdavis/.nextflow_singularity/depot.galaxyproject.org-singularity-gffcompare%3A0.12.6--h4ac6f70_2.img


RGT=/scratch/fl3/jdavis/reference_files/RGT_Planet_v2.gtf
#Ref guided files
STref=gffs/refguided/outputAnnotation_STref.gff3
FLAMESref=gffs/refguided/outputAnnotation_FLAMESref.gff3
BAMBUref=gffs/refguided/outputAnnotation_BAMBUref.gff3
FLAIRref=gffs/refguided/outputAnnotation_FLAIRref.gff3
IQref=gffs/refguided/outputAnnotation_IQref.gff3

#De novo files
BAMBUdenovo=gffs/denovo/outputAnnotation_BAMBUnoref.gff3  
IQdenovo=gffs/denovo/outputAnnotation_IQnoref.gff3
STdenovo=gffs/denovo/outputAnnotation_STnoref.gff3


#Compare ref
singularity run $gffcompare gffcompare $FLAMESref $BAMBUref $FLAIRref $IQref $STref $RGT
#This gives 72572 transcript structures 

#Compare de novo
#singularity run $gffcompare gffcompare $BAMBUdenovo $IQdenovo $STdenovo
#54801 transcript structures 
