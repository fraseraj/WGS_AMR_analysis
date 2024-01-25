#!/bin/bash

# medaka polishing of flye draft assembly using ONT reads, 1st of 3 polishing steps.
# needs to run from the parent directory which conatins all the individual assem_sample_id directories

assem_prefix="assem"

for assem_dir in ${assem_prefix}*; do 

 #Extract the sample ID from the "assem" directory name 
  sample_id=${assem_dir#"$assem_prefix"}
  
  echo "running medaka_concensus on draftassem${sample_id}"
  
 
  #run medaka_concensus
 medaka_consensus -i "${assem_dir}/QC${sample_id}.fastq.gz" -d "${assem_dir}/flyeassem${sample_id}/${sample_id}_flyeassem.fasta" -o "${assem_dir}/medakapolished${sample_id}" -t 8 -m r941_min_sup_g507
 
  if [ -e "${assem_dir}/medakapolished${sample_id}" ]; then # -e is the test condition - checking if the medakapolished.fasta exists.

    echo "Medaka completed successfully for sample ${sample_id}"

  else

    echo "Medaka: failed for sample ${sample_id}"

  exit 1 #if the medakapolished.fasta file is not found the loop will terminate 

  fi

  #rename the consensus.fasta file based on the sample id
  mv "${assem_dir}/medakapolished${sample_id}/consensus.fasta" "${assem_dir}/medakapolished${sample_id}/${sample_id}_medaka.fasta"


done
