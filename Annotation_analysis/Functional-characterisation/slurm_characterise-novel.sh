#!/bin/bash -l

#SBATCH --job-name=functionalCharacterisation
#SBATCH --account=fl3
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --time=10:00:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --export=ALL
#SBATCH --mem=30GB

module load singularity/4.1.0-slurm
module load blast/2.12.0--pl5262h3289130_0

genome=/scratch/fl3/jdavis/REFERENCES/RGT_2_2024/220816_RGT_Planet_pseudomolecules_and_unplaced_contigs_CPclean.fasta
gff_id=STref
gff=/scratch/fl3/jdavis/final_annotations/final_results/annotations/outputAnnotation_STref.gff3

agat=/software/projects/fl3/jdavis/.nextflow_singularity/depot.galaxyproject.org-singularity-agat%3A1.4.1--pl5321hdfd78af_0.img

### Turn list of novel transcripts into GFF ###
awk '{print $0; print $0}' ../Manual-comparison/novel_transcripts/STref_novel.txt > ${gff_id}_duplicated.txt
awk 'NR%2==1 {print "ID=" $0 ";"} NR%2==0 {print "Parent=" $0}' ${gff_id}_duplicated.txt > ${gff_id}_modified.txt
awk '{print "\\b" $0 "\\b"}' ${gff_id}_modified.txt | grep -E -f - $gff > ${gff_id}_transcripts.gff

rm ${gff_id}_duplicated.txt ${gff_id}_modified.txt

#Convert to fa for blastx search
singularity run $agat agat_sp_extract_sequences.pl --gff ${gff_id}_transcripts.gff -f $genome -o ${gff_id}-proteins.fa --merge

### Compare to PanBaRT ###
#wget https://ics.hutton.ac.uk/panbart20/downloads/PanBaRT20_transuite_transfeat_pep_renamed.fasta.gz
#gunzip PanBaRT20_transuite_transfeat_pep_renamed.fasta.gz
#makeblastdb -in $bart_ref -title "PanBaRT-proteins" -dbtype prot
mkdir PanBaRT
mv PanBaRT20* PanBaRT
bart_ref=PanBaRT/PanBaRT20_transuite_transfeat_pep_renamed.fasta

blastx -html -num_threads 64 -query ${gff_id}-proteins.fa -db $bart_ref \
-outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qcovs qcovhsp" > ${gff_id}-blastALL.tsv


### Identify transcripts which are also seen in BaRT ###
awk '{if ($3 > 95 && $13 > 95) print $0}' ${gff_id}-blastALL.tsv > ${gff_id}-blast-HC.tsv
cat ${gff_id}-blast-HC.tsv | cut -f1 | sort | uniq > ${gff_id}_BaRTnovel.txt

grep -w -vFf ${gff_id}_BaRTnovel.txt ../Manual-comparison/novel_transcripts/STref_novel.txt > ${gff_id}_NOVEL_FINAL.txt

#Generate gff file with only novel transcripts
awk '{print $0; print $0}' ${gff_id}_NOVEL_FINAL.txt > ${gff_id}_NOVEL_FINAL_duplicated.txt
awk 'NR%2==1 {print "ID=" $0 ";"} NR%2==0 {print "Parent=" $0}' ${gff_id}_NOVEL_FINAL_duplicated.txt > ${gff_id}_NOVEL_FINAL_modified.txt
awk '{print "\\b" $0 "\\b"}' ${gff_id}_NOVEL_FINAL_modified.txt | grep -E -f - $gff > ${gff_id}_NOVEL_FINAL_transcripts.gff
rm *duplicated.txt *modified.txt

singularity run $agat agat_convert_sp_gxf2gxf.pl -g ${gff_id}_NOVEL_FINAL_transcripts.gff -o ${gff_id}_NOVEL_FINAL_transcripts_clean.gff

### Convert to protein fa for interproscan ###
singularity run $agat agat_sp_extract_sequences.pl --gff ${gff_id}_NOVEL_FINAL_transcripts_clean.gff -f $genome -t cds -p --cfs --cis -o ${gff_id}-novel_proteins.fa
mkdir input output temp
mv ${gff_id}-novel_proteins.fa input


### Interproscan ###
#curl -O http://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.73-104.0/alt/interproscan-data-5.73-104.0.tar.gz
#tar -pxzf interproscan-data-5.73-104.0.tar.gz

#singularity pull docker://interpro/interproscan:5.73-104.0
interpro=interproscan_5.73-104.0.sif

singularity exec \
    -B $PWD/interproscan-5.73-104.0/data:/opt/interproscan/data \
    -B $PWD/input:/input \
    -B $PWD/temp:/temp \
    -B $PWD/output:/output \
    $interpro \
    /opt/interproscan/interproscan.sh \
    --input /input/${gff_id}-novel_proteins.fa  \
    --disable-precalc \
    -goterms \
    --output-dir /output \
    --tempdir /temp

#Find out how many have predicted functions overall and put them into a list for manual validation
grep 'GO:' output/${gff_id}-novel_proteins.fa.tsv | cut -f 1 | sort | uniq | wc -l
grep 'GO:' output/${gff_id}-novel_proteins.fa.tsv | cut -f 1 | sort | uniq > ${gff_id}-novel-functional-forValidation.txt

#Turn into csv for Rstudio analysis
tr '\t' ',' < output/${gff_id}-novel_proteins.fa.tsv > ${gff_id}-novel_proteins.fa.csv


rm *.log
