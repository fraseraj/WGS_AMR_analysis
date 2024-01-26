#!/bin/bash

# Use polypolish for step 2 of polishing
# this is the first step of polishing using short reads, the input draft assembly has been assembled using flye and has been polsihed with ONT reads using Medaka
# code relies on each fastq file being located within a directory with the same ID number with the prefix 'assem_'
# script must be run in the parent directory which contains all the individual directories which contain the ONT fatq reads


assem_prefix="assem"

for assem_dir in ${assem_prefix}*; do

 #Extract the sample ID from the "assem" directory name
  sample_id=${assem_dir#"$assem_prefix"}

  echo "polishing ${sample_id}"

  #index mascura polished draft assembly
  bwa index "${assem_dir}/medakapolished${sample_id}/${sample_id}_medaka.fasta" 
  # align set1 of short reads to draft assembly 
  bwa mem -t 8 -a "${assem_dir}/medakapolished${sample_id}/${sample_id}_medaka.fasta" "${assem_dir}/QC${sample_id}_1SR.fastq.gz" > "${assem_dir}/${sample_id}_alignments1.sam"
  # align set2 of short reads to draft assembly 
  bwa mem -t 8 -a "${assem_dir}/medakapolished${sample_id}/${sample_id}_medaka.fasta" "${assem_dir}/QC${sample_id}_2SR.fastq.gz" > "${assem_dir}/${sample_id}_alignments2.sam"
  #run polypolish filter
  polypolish filter --in1 "${assem_dir}/${sample_id}_alignments1.sam" --in2 "${assem_dir}/${sample_id}_alignments2.sam" --out1 "${assem_dir}/${sample_id}_filtered1.sam" --out2 "${assem_dir}/${sample_id}_filtered2.sam"
  # run polypolish polish
  polypolish polish "${assem_dir}/medakapolished${sample_id}/${sample_id}_medaka.fasta" "${assem_dir}/${sample_id}_filtered1.sam" "${assem_dir}/${sample_id}_filtered2.sam" > "${assem_dir}/${sample_id}_polypolish.fasta"
  

  #if/else statement to check if polypolish has completed succesfull - based on checking the assembly.fasta file has been produced 
  if [ -e "${assem_dir}/${sample_id}_polypolish.fasta" ]; then # -e is the test condition - checking if the polypolish.fasta file exists.

    echo "Polypolish completed successfully for sample ${sample_id}"

  else

    echo "Error: polypolish failed for sample ${sample_id}"

    exit 1 #if the polypolish.fasta file is not found the loop will terminate 

  fi

done
