
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
# 3 commands



# How many clean paired reads do you have ?



### Run getorganelle with the plant "recipe"
# think about the options you want to use!
# don't forget to set up your environment
# 3 commands


### Check the quality of the plastome assembly by mapping the reads on the assembled plastome or (at least one of the) scaffolds to see the coverage and if there are assembly issues
# don't forget to set up your environment
# 4 commands


## Look at the mapping statistics
# 1 command

# Transform the file with the mapping into a file that we can look at
# 1 command

# look at the mapping
http://ugene.net/download-all.html
Download the linux package
Extract manually in Softwares
Go to ~/Softwares/ugene-49.1
Run ./ugeneui
The app should launch
Then just click on Open File, select your file, and Import


### When satisfied by the assembly, annotate the plastome or scaffolds
# 1 website



