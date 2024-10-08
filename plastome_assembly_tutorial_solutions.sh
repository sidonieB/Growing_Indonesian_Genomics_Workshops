#### Tutorial to assemble a chloroplast genome from Illumina paired-end reads for one sample

#### First, the software GetOrganelle is installed together with the instructor
#### Then for the next steps (read cleaning, plastome assembly, read mapping), you have to find what software to use and what commands to run
#### All software and commands have been demonstrated in the past day, except GetOrganelle
#### For GetOrganelle, you are expected to look at the github page and decide what command to use, with help from the instructor
#### Semangat! :)


### install GetOrganelle

# install getorganelle through bioconda
conda create -n getorganelle
conda activate getorganelle
conda install -c bioconda getorganelle

# install the relevant database
get_organelle_config.py --add embplant_pt,embplant_mt

# deactivate the environment
conda deactivate


### Make sure your reads are clean
# Run fastqc on both files
for f in *.gz; do (/home/ontasia1/Softwares/FastQC/fastqc $f); done

# Look at the fastqc html report: what does it tell you about the quality ? About the adapters?
# Use this to decide on quality thresholds for trimmomatic

# Run trimmomatic on the sample
# Make sure you adapt the command for your case, with the suitable quality thresholds and adapter file!
cd ~/Softwares/Trimmomatic-0.39
java -jar trimmomatic-0.39.jar PE -phred33 ~/Documents/Plastome/*R1_001.fastq.gz ~/Documents/Plastome/*R2_001.fastq.gz -baseout ~/Documents/Plastome/AB_trimmed ILLUMINACLIP:/home/ontasia1/Softwares/Trimmomatic-0.39/adapters/TruSeq3-PE-2.fa:1:30:7:2:true SLIDINGWINDOW:4:30 LEADING:30 MINLEN:40

# Run fastqc again on the trimmed paired files
for f in *trimmed*; do (/home/ontasia1/Softwares/FastQC/fastqc $f); done
# How many clean paired reads do you have ?
# Do you need all the reads ? (in most cases you will want all of them so you can skip the next step)


### If you just want to use a subset of your reads, you can subsample them randomly like this:
# install seqtk
git clone https://github.com/lh3/seqtk.git;
cd seqtk; make
# use it to randomly subsample fastq reads (keep the seed -s the same for both R1 and R2!)
seqtk sample -s 123 reads1.fq 12000000 > sub_reads1.fq
seqtk sample -s 123 reads2.fq 12000000 > sub_reads2.fq


### Run getorganelle with the plant "recipe"
# think about the options you want to use!
# don't forget to set up your environment

conda activate getorganelle

get_organelle_from_reads.py -1 forward_reads.fastq -2 reverse_reads.fq -o plastome_output -R 15 -k 21,45,65,85,105 -F embplant_pt -t 8 --max-reads 12000000

conda deactivate


### Check the quality of the plastome assembly by mapping the reads on the assembled plastome or the scaffolds to see the coverage and if there are assembly issues
# You do not need to use paleomix, you could just use bwa separately, but let's practice paleomix, it gives us nice stats at the end
# If the assembly was not complete you could map reads on a complete reference of a closely related species to see if there are gaps corresponding to scaffold ends
# Then you can decide if you should redo GetOrganelle, maybe with a custom "seed"

# don't forget to set up your environment

## Make a paleomix configuration file (yaml file)
conda activate paleomix
paleomix bam_pipeline makefile > plastome_makefile.yaml

## To edit the yaml file you should look at explanations here: 
https://paleomix.readthedocs.io/en/stable/bam_pipeline/usage.html

## Edit the reference genome path in the yaml file:

# Map of prefixes by name, each having a Path key, which specifies the
# location of the BWA/Bowtie2 index, and optional label, and an option
# set of regions for which additional statistics are produced.
Prefixes:
  # Replace 'NAME_OF_PREFIX' with name of the prefix; this name
  # is used in summary statistics and as part of output filenames.
  ABplastome:
    # Replace 'PATH_TO_PREFIX' with the path to .fasta file containing the
    # references against which reads are to be mapped. Using the same name
    # as filename is strongly recommended (e.g. /path/to/Human_g1k_v37.fasta
    # should be named 'Human_g1k_v37').
    Path: ~/Documents/Plastome/*.path_sequence.fasta

## Leave defaults for the trimming (compare with Oscar's tutorial)

## Edit the sample info in the yaml file:

# Mapping targets are specified using the following structure. Uncomment and
# replace 'NAME_OF_TARGET' with the desired prefix for filenames.
AB:
   #  Uncomment and replace 'NAME_OF_SAMPLE' with the name of this sample.
  AB:
     #  Uncomment and replace 'NAME_OF_LIBRARY' with the name of this sample.
    AB:
       # Uncomment and replace 'NAME_OF_LANE' with the name of this lane,
       # and replace 'PATH_WITH_WILDCARDS' with the path to the FASTQ files
       # to be trimmed and mapped for this lane (may include wildcards).
      Lane_1: /home/ontasia1/Document/Plastome/AB_trimmed_{Pair}P

## Edit the aligner section in the yaml file:

# Settings for aligners supported by the pipeline
  Aligners:
    # Choice of aligner software to use, either "BWA" or "Bowtie2"
    Program: BWA
    # Settings for mappings performed using BWA
    BWA:
      # One of "backtrack", "bwasw", or "mem"; see the BWA documentation
      # for a description of each algorithm (defaults to 'backtrack')
      Algorithm: mem
      # Filter aligned reads with a mapping quality (Phred) below this value
      MinQuality: 0
      # Filter reads that did not map to the reference sequence
      FilterUnmappedReads: yes
      # May be disabled ("no") for aDNA alignments with the 'aln' algorithm.
      # Post-mortem damage localizes to the seed region, which BWA expects to
      # have few errors (sets "-l"). See http://pmid.us/22574660
      UseSeed: yes
      # Additional command-line options may be specified for the "aln"
      # call(s), as described below for Bowtie2 below.


## Run paleomix
paleomix bam run plastome_makefile.yaml

conda deactivate

## Look at the statistics
less *.summary

# Transform the file with the mapping into a file that we can look at = Transform the resulting bam file in a sam file
~/Softwares/samtools/bin/samtools view -h -o AB.sam AB.bam

# look at the mapping using ugene
# install ugene
http://ugene.net/download-all.html
Download the linux package
Extract it manually in Softwares
# run ugene (from the terminal)
Go to ~/Softwares/ugene-49.1
Run ./ugeneui
The app should launch, then you can open the sam file and zoom in to see the reads


### When satisfied by the assembly, annotate the plastome or scaffolds
CHLOROBOX



