

# install weighted astral
# download the directory for linux from here: https://github.com/chaoszhang/ASTER/blob/master/tutorial/astral-hybrid.md
# move the directory to Softwares
cd 
make





# Update R and install Rstudio
sudo apt update
sudo apt -y upgrade

# Below is from https://cran.usk.ac.id/ (except that we do not install the packages)

sudo apt update -qq
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
sudo apt install --no-install-recommends r-base


# download Rstudio from https://posit.co/download/rstudio-desktop/#download (no need to download again if done already, but run again the command)
# Chose the package for Ubuntu 22/Debian 12
# Move the file to Softwares and from there run:
sudo apt install -f ./rstudio-2023.12.1-402-amd64.deb

# If you get an error wabout "magick" when installing the ggimage package in R, first install libmagick in the terminal
sudo apt-get install libmagick++-dev
# Then install magick in R, then install ggimage (see R script)
# By the way, this error was solved with the help of Jeronimo by asking the following to chatGPT: 
# "Hi, I am trying to install an R package and got this error with this command line. Can you help?" + full error text copied from R





# install paleomix and dependencies
# https://paleomix.readthedocs.io/en/stable/installation.html#conda-installation

cd ~/Softwares/
sudo apt-get install adapterremoval bowtie2
sudo apt-get install python3-pip
sudo apt-get install libz-dev libbz2-dev liblzma-dev python3-dev


curl -fL https://github.com/MikkelSchubert/paleomix/releases/download/v1.3.8/paleomix_environment.yaml > paleomix_environment.yaml
conda env create -n paleomix -f paleomix_environment.yaml

conda env list

conda activate paleomix
 
mkdir -p ~/install/jar_root/
ln -s /home/ontasia*/anaconda3/envs/paleomix/share/picard-*/picard.jar ~/install/jar_root/

conda deactivate


# Copy the data for population genomics in Documents and extract it




