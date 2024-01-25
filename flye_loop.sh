#!/bin/bash

# Create assembly using flye and ONT read. Assemblies will later be polished using Illumina short reads. 
# --nano-hq flag used as fast5 data was basecalled super accurately using Guppy5
# code relies on each fastq file being located within a directory with the same ID number with the prefix 'assem_'
# script must be run in the parent directory which contains all the individual directories which contain the ONT fatq reads


assem_prefix="assem"

for assem_dir in ${assem_prefix}*; do

 #Extract the sample ID from the "assem" directory name
  sample_id=${assem_dir#"$assem_prefix"}

  echo "Generating Flye draft assembly for sample ${sample_id}"

  #run flye
  flye --nano-hq "${assem_dir}/QC${sample_id}.fastq.gz" --threads 8 --out-dir "${assem_dir}/flyeassem${sample_id}"

  #if/else statement to check if flye has completed succesfull - based on checking the assembly.fasta file has been produced 
  if [ -e "${assem_dir}/flyeassem${sample_id}/assembly.fasta" ]; then # -e is the test condition - checking if the assembly.fasta exists.

    echo "Flye completed successfully for sample ${sample_id}"

  else

    echo "Error: Flye failed for sample ${sample_id}"

    exit 1 #if the assembly.fasta file is not found the loop will terminate 

  fi

  #rename the assembly.fasta file and the assembly_graph.gfa files based on the sample id
  mv "${assem_dir}/flyeassem${sample_id}/assembly.fasta" "${assem_dir}/flyeassem${sample_id}/${sample_id}_flyeassem.fasta"
  mv "${assem_dir}/flyeassem${sample_id}/assembly_graph.gfa" "${assem_dir}/flyeassem${sample_id}/${sample_id}_flyeassem.gfa"

done


