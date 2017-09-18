#!/bin/bash

echo 'Importing variables and calling software...'
# import variables
source 00_PrepareDataDir.sh
echo '...done.'
echo '---'

# get pacbio data from archive
cd $pacbio_dir

# subset the isoseq full-length polished isoforms 
echo 'Generating a subset of the fasta isoseq mapping to the genome...'
echo 'Generating a list of mapped reads, from alignment file...'
cat isoseq_gmap.sam | awk '$3==4 {print $0}' | cut -f1 | sort | uniq > pacbioIS_mappedID.txt
echo 'Generating subset of fastq according to the generated list...'
grep -A3 -f pacbioIS_mappedID.txt isoseq_isoforms.fastq | grep -v '^--' > pacbioIS_subset.fastq
echo 'Generating archive including only fastq mapping to chr4...'
tar zcf subset_PBIS.tar.gz pacbioIS_subset.fastq
archive_name=$(ls subset_PBIS.tar.gz)
size_subsetIS=$(ls -lh subset_PBIS.tar.gz | cut -f5 -d '')
echo "The generates archive was written to $archive_name and has size: $size_subset"
echo '...done.'

# uploaded on dropbox
