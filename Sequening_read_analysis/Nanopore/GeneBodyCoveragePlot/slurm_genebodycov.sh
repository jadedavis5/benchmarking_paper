#!/bin/bash -l

#SBATCH --job-name=genebodycov
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
module load samtools/1.15--h3843a85_0

gtf=/scratch/fl3/jdavis/reference_files/RGT_Planet_v2.gtf
nb29=/scratch/fl3/jdavis/manuscript/work/72/1fdd634b43b96d37972e81d7219936/rna_010_ptt_f32_NB29_A_220816_RGT_Planet_pseudomolecules_and_unplaced_contigs_CPclean_aln_sorted.bam
control=/scratch/fl3/jdavis/manuscript/work/28/8548645ffdf79a10cd55084504d099/rna_011_ptt_f32_control_220816_RGT_Planet_pseudomolecules_and_unplaced_contigs_CPclean_aln_sorted.bam

gt=/software/projects/fl3/jdavis/.nextflow_singularity/depot.galaxyproject.org-singularity-genometools-genometools%3A1.6.5--py311h396876e_3.img
#singularity run $gt gt gtf_to_gff3 $gtf > RGT_Planet_v2.gff

agat=/software/projects/fl3/jdavis/.nextflow_singularity/depot.galaxyproject.org-singularity-agat%3A1.4.1--pl5321hdfd78af_0.img
#singularity run $agat agat_convert_sp_gff2bed.pl --gff RGT_Planet_v2.gff -o RGT_Planet_v2.bed #stalls if not enough memory

#have to move the .csi to .bai so rseqc can detect the indexes
#samtools index -c $nb29
#samtools index -c $control

#singularity pull https://depot.galaxyproject.org/singularity/rseqc%3A5.0.4--pyhdfd78af_1
rseqc=../rseqc%3A5.0.4--pyhdfd78af_1

singularity run $rseqc geneBody_coverage.py -r RGT_Planet_v2.bed \
-i $nb29,$control \
-o GeneBodyCoverage
