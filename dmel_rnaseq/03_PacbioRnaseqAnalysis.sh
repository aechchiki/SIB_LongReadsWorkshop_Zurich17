#!/bin/bash

# estimation of time per command using 1 core per command

echo 'Importing variables and calling software...'
# import variables
source 00_PrepareDataDir.sh
# import software
source 00_CallSoftware.sh
echo '...done.'
echo '---'

# get minion data from archive
cd $pacbio_dir

# copy if not already in the target directory
echo 'Copying & unzipping data to working directory...'
wget https://www.dropbox.com/s/63o9fntdm9wptn4/subset_PBIS.tar.gz
# time: 1min, size: 626K
tar -xzf subset_PBIS.tar.gz
# time: 20s

# fastq to fasta 
cat pacbioIS_subset.fastq | awk '{if(NR%4==1) {printf(">%s\n",substr($0,2));} else if(NR%4==2) print;}' > pacbioIS_subset.fasta

# align to reference genome
echo 'Aligning sample to the reference...'
gmap -d gmapidx -D $ref_dir pacbioIS_subset.fasta -f gff3_match_cdna -n 0 > pacbio_gmap.gff3
# time: 9s

# comparison of experimental transcripts to reference annotation
echo 'Converting gmap_gff3 to standard gtf2...'
gff2gtf.py pacbio_gmap.gff3 > pacbio_gmap.gtf
echo 'Comparing to reference annotation using cuffcompare...'
cuffcompare -G -r $ref_dir/Dmel_chr4.gtf pacbio_gmap.gtf 

echo 'All done. Please check output in $pacbio_dir"cuffcmp.minion_gmap.gtf.tmap"'
