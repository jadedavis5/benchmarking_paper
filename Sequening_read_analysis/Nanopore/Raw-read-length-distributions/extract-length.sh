#!/bin/bash -l

#SBATCH --job-name=extractlength
#SBATCH --account=fl3
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=10:00:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --export=ALL

module load singularity/4.1.0-slurm

#singularity pull https://depot.galaxyproject.org/singularity/seqkit%3A2.9.0--h9ee0642_0
seqkit=seqkit%3A2.9.0--h9ee0642_0

nb29=../raw_nanopore_reads/manuscript/rna_010_ptt_f32_NB29_A.fastq.gz
control=../raw_nanopore_reads/manuscript/rna_011_ptt_f32_control.fastq.gz

singularity run $seqkit seqkit fx2tab --name --length $nb29 > rna_010_ptt_f32_NB29_A_LENGTHS.txt
singularity run $seqkit seqkit fx2tab --name --length $control > rna_011_ptt_f32_control_LENGTHS.txt

