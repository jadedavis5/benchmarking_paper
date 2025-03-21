#!/bin/bash -l

#SBATCH --job-name=isoquant
#SBATCH --account=fl3
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --export=ALL

module load singularity/4.1.0-nompi

gffcompare=/software/projects/fl3/jdavis/.nextflow_singularity/depot.galaxyproject.org-singularity-gffcompare%3A0.12.6--h4ac6f70_2.img
isoquant=/software/projects/fl3/jdavis/.nextflow_singularity/depot.galaxyproject.org-singularity-isoquant%3A3.6.3--hdfd78af_0.img

genome=/scratch/fl3/jdavis/REFERENCES/RGT_2_2024/220816_RGT_Planet_pseudomolecules_and_unplaced_contigs_CPclean.fasta
gtf=/scratch/fl3/jdavis/REFERENCES/RGT_2_2024/RGT_Planet_v2.gtf
nb29=/scratch/fl3/jdavis/final_annotations/rna_011_ptt_f32_nb29_220816_RGT_Planet_pseudomolecules_and_unplaced_contigs_CPclean_aln_sorted.bam

### Identify disease resistance associated transcripts ###

#Find disease associated transcripts 
wget -O Panbarlex_disease-resistance https://panbarlex.ipk-gatersleben.de/functional_annotation/search/disease%20resistance/download
awk -F'\t' '{if ($1 == "RGT_PLANET") print $2}' Panbarlex_disease-resistance | sort > Panbarlex_RGT_PLANET_disease-resistance.txt

#Find expressed transcripts
singularity run $isoquant isoquant.py --genedb $gtf --bam $nb29 --reference $genome --no_model_construction --data_type nanopore
awk '{if ($2 > 20) print $1}' isoquant_output/OUT/OUT.transcript_counts.tsv | sort  > RGT_v2_expressedInDisease.txt

#Compare 
comm -12 Panbarlex_RGT_PLANET_disease-resistance.txt RGT_v2_expressedInDisease.txt > FINAL-Expressed-Disease-transcripts.txt

### Identify transcripts novel to RGT Planet for reference guided annotations ###

mkdir novel_transcripts
for gff_id in IQref STref BAMBUref FLAIRref FLAMESref
do

	gff="/scratch/fl3/jdavis/final_annotations/final_results/annotations/outputAnnotation_${gff_id}.gff3"
	singularity run $gffcompare gffcompare -R -r $gtf -o ${gff_id}_gffcompareCMP $gff

	base_dir=$(dirname "$gff")
	base_name=$(basename "$gff")
	tmap="${base_dir}/${gff_id}_gffcompareCMP.${base_name}.tmap"
	rm *CMP*
	
	cat $tmap | awk '$3=="u"{print $0}' | cut -f5 | sort | uniq > novel_transcripts/${gff_id}_novel.txt

done
