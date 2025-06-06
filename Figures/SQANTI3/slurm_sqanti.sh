#!/bin/bash -l

#SBATCH --job-name=run-sqanti3
#SBATCH --account=fl3
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=64
#SBATCH --time=10:00:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --export=ALL
#SBATCH --mem=40GB

module load singularity/4.1.0-slurm


#singularity build sqanti3.sif docker://anaconesalab/sqanti3
reference=/scratch/fl3/jdavis/REFERENCES/RGT_2_2024/RGT_Planet_v2.gtf
genome=/scratch/fl3/jdavis/REFERENCES/RGT_2_2024/220816_RGT_Planet_pseudomolecules_and_unplaced_contigs_CPclean.fasta

#Convert GFF3 files output from pipeline to GTF
#for run in STref STnoref BAMBUref BAMBUnoref IQref IQnoref FLAIRref
#do
#singularity run /software/projects/fl3/jdavis/setonix/containers/gffread_0.11.7.sif gffread outputAnnotation_${run}.gff3 -T -o GTF/outputAnnotation_${run}.gtf
#done

for run in STref STnoref BAMBUref BAMBUnoref IQref IQnoref FLAIRref
do
singularity run sqanti3_latest.sif sqanti3_qc.py /scratch/fl3/jdavis/final_annotations/final_results/annotations/GTF/outputAnnotation_${run}.gtf $reference $genome -o $run --short_reads shortRead.fofn
done


#Find out how many ISM in BAMBUnoref are 3' fragment (missing 5' end)
awk '{if ($6 == "incomplete-splice_match") print $15}' BAMBUnoref_classification.txt | sort | uniq -c


#Find out how many are intron retention 
for file in *_classification.txt
do
  echo $file
  cut -f 15 | grep 'intron_retention' | wc -l
done
