
# Bioinformatics of long read sequencing - ready for the third generation

## Contributors

Amina Echchiki <sup>1,2</sup>, Kamil Jaron <sup>1,2</sup> , Walid Gharib <sup>2,3</sup>

<sup>1: Department of Ecology and Evolution, University of Lausanne, CH-1015 Lausanne</sup>

<sup>2: SIB Swiss Institute of Bioinformatics, CH-1015 Lausanne</sup>

<sup>3: Bioinformatics unit, University of Bern, CH-3012 Bern</sup>


## Practical information

*When?* October 5th & 6th, 2017

*Where?* [Irchel Campus](http://www.uzh.ch/en/about/info/sites/irchel.html), University of Zürich, CH-8057 Zürich

*What?* [SIB training event](http://www.sib.swiss/training/upcoming-training-events/2017-longreads02), Hands-on session


## Aim

The aim of this practical session is to get your hands on real data generated from two different long-reads sequencing platforms: Oxford Nanopore (ONT) [MinION](https://nanoporetech.com/products/minion) and Pacific Biosciences (PacBio) [RSII](http://www.pacb.com/products-and-services/pacbio-systems/rsii/).


## Introduction

### Biological material

Last year, we analyzed genomic reads from long-reads platforms of the [lambda phage](https://en.wikipedia.org/wiki/Lambda_phage): it is a rather simple organism with small genome size (48kb) that made computations easier but not biologically interesting.

This year, we propose you to analyze both genomic and transcriptomic data from long-reads sequencing platforms from the fruit fly ([*Drosophila melanogaster*](https://en.wikipedia.org/wiki/Drosophila_melanogaster)), one of the genetically best-known eukaryotic organism. To make computations faster, we focused on assembling the smallest chromosome (chr. 4) and analyzing the transcriptomic reads mapping to it.

### Long reads technologies

TODO: compare short and long reads technologies for genome and transcriptome applications

#### PacBio RSII

TODO: terminology, reads, cool publications, applications, the iso-seq method, perspectives, new applications and innovation

#### ONT MinION

TODO: terminology, reads, cool publications, applications, perspectives, innovations

## How to connect to the computing platform

TODO: does it change with different OS?

You can use your user credentials that you received for this course (username and password) to activate the Docker container that we built for you (kudos Walid). This image contains all the software you will need for this tutorial. You can then access to the Amazon server (TODO IP adress) we have reserved for your computations.

TODO add maximal requirements per user.


## Hands on!

### Unix: useful tips

The system you are using as working platform is based on Ubuntu Linux: you can use Unix to communicate with it. We assume that you have familiarity with Unix, since you had the opportunity to take the [SIBWeb UNIX Fundamentals](https://edu.isb-sib.ch/course/view.php?id=82) e-learning module. In case you would like a refresh, we provide you a [UNIX cheat sheet](http://cheatsheetworld.com/programming/unix-linux-cheat-sheet/): the section `File system` should be enough to satisfy the purposes of this tutorial. Just keep in mind that we do not have the `vim` editor installed, so please use `nano` instead.

### File organization

On login, you should find yourself at home.

ⓘ To check your location, you can use the command `pwd` :

```
$ pwd
/home/<username>
```

Organisation is important to avoid getting lost in your data.

ⓘ To create a new directory, you can use the command `mkdir` :

```
mkdir <directory>
```

ⓘ To move to a directory, you can use the command `cd` :

```
cd <directory>
```

ⓘ To browse through directories, you can use relative path or absolute path:

```
cd .. # relative path, i.e. go to one level higher directory
cd /home/<username>/<directory> # absolute path
```

For our tutorial, we suggest a nested organisation, like follows:

TODO check with kamil what he agrees on

### Get the data

For the genomic part, we will make use of an existing [dataset](https://www.ncbi.nlm.nih.gov/sra/?term=SRX499318) of *D. melanogaster* DNA reads generated from PacBio RSII instrument. For the transcriptomic part, we will make use of two unpublished datasets of RNA reads, generated from PacBio RSII (with size selection) and MinION MkII (R7.3 flowcell).

⚠ The datasets you'll use for this tutorial consist of modified subsets of the above mentioned data. This operation was done with only intention to lower the computational resources load and running time.

ⓘ To save data from a given web resource given its location, use `wget`:

```
wget <URL>
```

You can download the subset of DNA reads from here // TODO Kamil.

You can download the subset of RNA reads from here (MinION) and here (PacBio) // TODO Amina (wait for the link to drive.sib.swiss).


### Read extraction

#### Generic HDF Format

The output of MinION and PacBio RSII are both stored in [Hierarchical Data Format (HDF5)](https://en.wikipedia.org/wiki/Hierarchical_Data_Format#HDF5). This is basically an archive file format specifically designed to store large amount of data allowing rapid access to its contents. In our case, these files do not only contain the raw reads, but also metadata information about generated during the sequencing run and the basecalling. For the purposes of this tutorial, we will only need the reads sequences and their qualities, which can be easily stored in a fastq file for subsequent processing.

ⓘ Data in HDF format can be explored using inbuilt [HDF5 tools](https://support.hdfgroup.org/HDF5/doc/RM/Tools.html), e.g.:

```
h5dump <HDF_file> # examine contents of HDF file and dump content to ASCII
```
#### MinION raw data format

Sequencing calls on a MinION platform are based on the detection of electric signal recorded through the nanopores of the flowcell, as the DNA/RNA fragment pass through it. Signal measurements are called *events*. The nature of the event depends on the nature of the nucleobases of the fragment entering the pore at a given time. Thus, the change of signal through time reflects the changes in nucleotide composition as the fragment passes through. This information is stored in Fast5 files (a type of HDF), one fast5 file per sequenced molecule. Basecalling is then achieved using algorithms based on HMM (Hidden Markov Model) or RNN (Recurrent Neural Nets). This is done by specialized software, which can be run locally (e.g., using [Albacore](https://nanoporetech.com/about-us/news/new-basecaller-now-performs-raw-basecalling-improved-sequencing-accuracy?utm_content=59855973&utm_medium=social&utm_source=twitter) for local basecalling directly from raw data) or on the ONT cloud (e.g., using [Metrichor](https://metrichor.com/) for basecalling through a step of *event detection*). The basecaller produces then one file per read, in pass/fail category if the basecalling was respectively successfull or not, including info about the nature of the read (template/complement/consensus 2D).

You can extract the dataset you previously downloaded using [poretools](https://github.com/arq5x/poretools), a toolkit for working with sequencing data from MinION. The usage is detailed in the [documentation](https://poretools.readthedocs.io/en/latest/).

ⓘ Good software generally comes with good documentation. To access the (not always comprehensive) command-line documentation, invoke the command using the `-h` / `--help` flag :

```
poretools --help
```

ⓘ If not otherwise specified, when a command is executed via interactive shell, output is written to stdout (standard output), which by default consists of the text terminal. To write the output to a file, use redirection with `>` ( greater-then) symbol:

```
cd $minion
poretools fastq <path/to/fast5/>*.fast5 > <poretools_out>.fastq
```

ⓘ A good practice is to compress your data to archive after processing, in order to save storage space on the disk. You can still visualize compressed files in a terminal with `zcat` or go back to the uncompressed data using `gzip -d <file.gz>`:

```
gzip -9 <poretools_out>.fastq
zcat <poretools_out>.fastq.gz | head
```

� Are you familiar with the fastq format? What does each line correspond to? [Hint](https://en.wikipedia.org/wiki/FASTQ_format)

� What are the other utilities embedded in the `poretools` toolkit? [Hint](https://poretools.readthedocs.io/en/latest/content/examples.html)

� How many reads are in this dataset? [Hint](https://poretools.readthedocs.io/en/latest/content/examples.html#poretools-stats)

� How would you change the command line if you wanted to only extract the reads corresponding to a high quality subset of the 2D reads? Are there any 2D reads with no complementary template/complement? Hint: how are the 2D reads generated? [Hint](https://poretools.readthedocs.io/en/latest/content/examples.html#poretools-fastq)

� Choose a 2D read at random. Look for the corresponding reads in 1D (template/complement). Do you see an improvement in the quality scores? [Hint](https://en.wikipedia.org/wiki/Phred_quality_score)

#### PacBio RSII raw data format

Sequencing calls on a PacBio RSII platform are based on the optical detection of the incorporation of a single phospholinked (type of) nucleotide. This is essentially the SMRT (Single Molecule Real Time) sequencing chemistry, and happens in ZMWs microwells (Zero Mode Waveguides) on the bottom of the flowcell (SMRTcell). At the bottom of ZMWs, a natural polymerase incorporates complementary bases to a DNA/cDNA fragment. Intuitively, the basecalling is done according to the corresponding base-level incorporation *events*, calculated based on the type of fluorescent dye (unique per nucleotide), over time. Optical raw data per SMRTcell is stored in a `bas.h5` (a type of HDF) and three associated `bax.h5` (each one containing a consecutive part of the nucleotide incorporation movie). In the `bax.h5`, you can find the basecalling information, alongside with metadata about the sequencing run and instrument settings. The `bas.h5` file is basically there to link the `bax.h5` files and contains run metadata. You can find extensive documentation about `*.h5` archive layout [here](http://files.pacb.com/software/instrument/2.0.0/bas.h5%20Reference%20Guide.pdf).

ⓘ Please note that this reads format is no longer used to store the basecalling information in newer instruments from PacBio, such as [Sequel](http://www.pacb.com/products-and-services/pacbio-systems/sequel/), in which data are stored in a [classical `*.bam` format](https://www.genomeweb.com/informatics/pacbio-unveils-plans-use-bam-format-sequence-data-user-community-weighs). However, all data produced by a RSII instrument will be still in this `*.h5` you are going to work with.

As for MinION reads, dedicated software allows to extract the basecalling information from these `*.h5` files. We have already prepared a fastq dataset to use for following analysis, but you can test the extraction on [this](TODO wget stuff - use the smallest subset we have) dataset.

```
cd $pacbio
mkdir testing && cd testing
wget url_of_stuff TODO
```

You can extract this dataset using [pbh5tools](https://github.com/PacificBiosciences/pbh5tools), a set of python scripts to extract fasta/q from `*.h5` reads. The usage is detailed in the [documentation](https://github.com/PacificBiosciences/pbh5tools/blob/master/doc/index.rst). You will need [`bash5tools.py`](https://github.com/PacificBiosciences/pbh5tools/blob/master/doc/index.rst#tool-bash5toolspy) script to extract the reads in `*.fastq` format.

```
bash5tools.py <file.bas.h5> --outFilePrefix <prefix> --readType subreads --outType fastq
gzip -9 <prefix>.fastq
```

� How many reads are in this dataset? From how many flowcells?

� How are they called according to the PacBio terminology? [Hint](http://files.pacb.com/software/smrtanalysis/2.2.0/doc/smrtportal/help/!SSL!/Webhelp/Portal_PacBio_Glossary.htm)

### Genome assembly

TODO Kamil

### Assessing assembly quality

TODO Kamil

### Transcriptome assembly

#### Introduction

Long reads allow easier rebuild of the transcriptome: ideally, the reads are long enough to allow the recovery of the full-length transcripts. This means skipping the reconstruction part, otherwise necessary for transcript assembly from shorter reads such as from Illumina. The issue is that, to date, long reads such as from PacBio and MinION platforms have much higher error rate than Illumina reads (e.g. HiSeq). This is why generating a consensus from raw reads and eventually go deeper in error correction are both essential steps before digging further into the characterization and analysis of the transcriptome.

For PacBio, a pipeline for transcriptome anaylsis is available, established and well maintained: the Iso-Seq method. For MinION data, there is no such advantage. One can think of tweaking the Iso-Seq method to make it handling raw data from non-PacBio platforms, but this is not straightforward, mainly due to the error rates and models that differ between technologies. Another approach would be to generate the consensus then correct it using de-novo or hybrid (short-reads based) error correction.

In this tutorial, we will give you an overview of the Iso-Seq method for PacBio RNA-seq data and a glance of error correction on MinION RNA-seq data, using the error correction step from Canu. 
