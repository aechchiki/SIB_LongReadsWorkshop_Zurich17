### Drosophila as the training dataset

This year we have decided to do some iso-seq as well. It is exciting and trendy usage of long read sequencing, but it is not that meaningful in prokaryotes.
Therefore we were thinking about taking a eukaryotic model.

Of course we could try to find a good yeast dataset (or something else with small genome),
but the thing is that we have very nice drosophila RNA-seq data of both major long read sequencing platforms.
Amina is also very familiar with this dataset.

We also figures out that we do not need to do the full genome, but we could easily assemble one chromosome only.
This would require us to map the long reads to reference and keep only the reads that map to one chromosome only.
Our RNA-seq data is of female flies, therefore we will go for the smallest autosome.

#### Get data

The sequencing data I will play with are ~100x coverage of genome of male _D. melanogaster_, [SRA experiment
SRX499318, SRA Study: SRP040522](https://www.ncbi.nlm.nih.gov/Traces/study/?acc=SRX499318).

```bash
# contains a convertor of .sra to .fastq - fastq-dump
module add UHTS/Analysis/sratoolkit/2.8.0
# dee-serv04
mkdir -p /scratch/local/kjaron/LongReadWorkshop/ && cd /scratch/local/kjaron/LongReadWorkshop/
# list all the SRR entries withing the SRX experiment
curl -l ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByExp/sra/SRX/SRX499/SRX499318/ > list_of_accessions
# dl .sra, convert it to .fq and remove .sra afterwards
for accesion in $(cat list_of_accessions); do
    wget ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByExp/sra/SRX/SRX499/SRX499318/$accesion/$accesion.sra
    fastq-dump --gzip $accesion.sra && rm $accesion.sra
done
```

For this dataset I do not have h5 files, it might be possible to retrieve them from .sra files, but I have not really tried (not sure if it is that important). I also need a ch4 indexed reference

```
mkdir -p reference && cd reference
wget ftp://ftp.ensemblgenomes.org/pub/metazoa/release-36/fasta/drosophila_melanogaster/dna/Drosophila_melanogaster.BDGP6.dna.chromosome.*.fa.gz
cat * > Dmel.ref.fa.gz
module add UHTS/Aligner/bwa/0.7.13
bwa index Dmel.ref.fa.gz
```

I cleaned folder s bit (reads to reads, refrence to reference). Now I want to find out how much I need to map to get a reasonable coverage (60 - 120x ??), so I just want to take a look deeply the genome is sequenced.

```bash
for i in `ls reads`; do
    ~/scripts/generic_genomics/fastq.gz2number_of_nt.sh reads/$i >> sequenced_nucleotides.txt
done
```

167.4645x, alright, I will use just half of cells (just because it is pointless to use all).
Now I will just map all the reads to genome keeping only uniquely mapping reads.

```bash
mkdir -p non_used_reads && cd reads
mv $(ls | head -21) ../non_used_reads && cd ..
module add UHTS/Analysis/samtools/1.3
for i in `ls reads`; do
    bwa mem -t 2 reference/Dmel.ref.fa.gz \
        reads/$i | samtools view -h -F 4 - | samtools view -hb -F 2048 - > mapping/$(basename $i .fastq.gz).bam &
done
```

sort bam files, index them and extract only reads mapping to ch4.

```bash
for i in *.bam; do samtools sort $i -o `basename $i .bam`.sort.bam; done
for i in *.sort.bam; do samtools index $i; done
cd ../filtered_mapping
for i in ../mapping/*sort.bam; do samtools view $i 4 > `basename $i .sort.bam`_map_to_ch4.bam; done
# 4 in the command means "View only records mapping to reference '4'."
```

Convert bam to fastq

```bash
module add UHTS/Analysis/picard-tools/2.2.1
mkdir -p ch4_reads
for i in filtered_mapping/*; do
    picard-tools SamToFastq I=$i FASTQ=ch4_reads/$(basename $i .bam).fastq QUIET=true
done
```

```bash
cat ch4_reads/* > dmel_ch4_reads.fastq
gzip -9 dmel_ch4_reads.fastq

module add UHTS/Quality_control/fastqc/0.11.2
mkdir ch4_reads_QC
# fastqc -d tmp -o ch4_reads_QC dmel_ch4_reads.fastq.gz
# runinng out of memory on vital-it - should I run it locally?
# is there a nicer way how to qc long reads?
```

Canu assenbly

```bash
module add UHTS/Assembler/canu/1.4
canu -p dmel_ch4 -d asm_run3 genomeSize=2m -maxThreads=1 useGrid=false -pacbio-raw dmel_ch4_reads.fastq.gz
# gatekeeperCreate did NOT finish successfully; too many short reads.  Check your reads!
```

Assembly takes ~1h20' on single core, dual core will be about half (it's a well parallelized program).

NOTE : ask participants to chose their own parameters for assembly, so they can compare impact of parameters on the assembly.

NOTE : make clear to audience why mapping is such an issue for long reads while short reads assembly can be very much mapping-less and why complexity of mapping of short reads to assembly (all vs reference) is different to problem of mapping for long read assembly (all vs all).

```
mkdir mini_asm & cd mini_asm
minimap2 -x ava-pb ../reads/dmel_ch4_reads.fastq ../reads/dmel_ch4_reads.fastq > overlaps.paf
miniasm -f ../reads/dmel_ch4_reads.fastq overlaps.paf > ch4.gfa
```

TODO mapping

```bash
minimap dmel_ch4_reads.fastq.gz ch4_asm.fa
# how to view the mapping? How would coverage plot looked like?
```
