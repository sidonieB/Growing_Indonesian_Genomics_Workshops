
###############################################################
# Script to plot ASTRAL trees with branch labels
###############################################################

#### Load packages
#### Only run the installation commands if the packages are not installed

install.packages("ape")
library(ape)
install.packages("BiocManager")
library(BiocManager)
BiocManager::install("ggtree")
library(ggtree)
BiocManager::install("treeio")
library(treeio)
# Go to your linux terminal and run
# sudo apt-get install libmagick++-dev
# then go on
BiocManager::install("magick")
install.packages("ggimage")
library(ggimage)
library(gridExtra)



#### Load the functions

# Function makes a dataframe using the tree labels to format the data needed to make pie charts (or any plot) of the LPP scores (or any other data from AS_all@data)
# Load this function before going further
# You can change q1,q2,q3 by pp1,pp2,pp3 if you want pie charts with LPPs instead of quartet scores
QS_calc <- function(AS_A) {
  Q1 <- as.numeric(AS_A@data$q1) * 100 # Get quartet score 1 for each branch as a percentage
  Q <- as.data.frame(Q1)
  Q$Q2 <- as.numeric(AS_A@data$q2) * 100 # Get quartet score 2 for each branch as a percentage
  Q$Q3 <- as.numeric(AS_A@data$q3) * 100 # Get quartet score 3 for each branch as a percentage
  Q$P1 <- round(as.numeric(AS_A@data$pp1),2) # Get local posterior probability 1 for each branch, rounded to 2 decimals
  #Q$EN <- round(as.numeric(AS_A@data$EN)) # Get number of genes subtending each branch
  Q$node <- AS_A@data$node # Get node number for each branch
  return(Q)
}


# Main function to plot the tree
# The function exports a plot for the tree as a pdf and also returns the plot that can be stored in a list 
# so that multiple trees can be plotted together after running the function on multiple trees
# Modify the function to fit your aesthetic desires (eg change colors etc)
# You need to change the pdf size inside the function depending on the number of taxa in the tree as indicated
# The function can also export a txt file with the tip labels in case useful

# intree: the tree to plot
# intree_name: the name of the tree to be used as plot title
# These are specified when you run the function, not here
# Load this function before going further


plot_astral <- function(intree, intree_name){

   # import tree (use a tree rooted with pxrr directly after getting it from ASTRAL)
   AS <- read.astral(intree)
   
   # do some relabelling if needed
   #AS@phylo$tip.label[17] <- "Truongsonia_lecongkietii_LY1525"
   #AS@phylo$tip.label[18] <- "Truongsonia_lecongkietii_LY1521A"
   
   # or more general relabelling, such as replacing underscore by space in all labels
   # AS@phylo$tip.label <- gsub("_", " ", AS@phylo$tip.label)
   
   # Format data to make pie charts (i.e. it runs the QS_calc function defined above)
   Q <- QS_calc(AS)
   
   # plot and ladderize the tree, without using the ASTRAL branch lengths, then attach the data to the object and plot some labels as specified
   # Change if want to plot different values or with different sizes or colors
   p <- ggtree(AS@phylo, ladderize=T, branch.length = "none") %<+% Q + 
     geom_tiplab(size=4, hjust= -0.05) + # format tip labels
     xlim_tree(10) + # decide width of the tree
     ggtitle(intree_name)+ # add title
     geom_nodelab(aes(x=branch, label=P1), vjust=-0.5, size=4) # Add LPP 1 above branches
     #geom_nodelab(aes(x=branch, label=EN), vjust=1.5, size=3) # Add gene number under branches

   # export tip list (useful to compare taxa present in different trees)
   #write(AS@phylo$tip.label, file= paste0(intree_name,"_tips.txt"))

   # check node labels if necessary
   #p + geom_text2(aes(subset=!isTip, label=node), hjust=-.3, size = 4)

   # make pie charts (takes some time if tree is big)
   pies <- nodepie(Q, cols=1:3, color=c(Q1='red', Q2='cyan', Q3='gray')) #, alpha=.6) # change style as needed, alpha is for transparency
   
   # Add pie charts to the tree
   p <- inset(p, pies, width=0.1, height=0.1, hjust=0.05) # change size if pies too big/small (better check first how it looks in the exported file)

   # plot in a pdf
   # Change size as required (eg for one tree with 200 taxa: 15, 45; with 450 taxa: 10,65; with 15 taxa: 5,7)
   # Change suffix if you wish
   pdf(paste0(intree_name,"_PP1_QSpies.pdf"), 10, 10) 
   plot(p)
   dev.off()
   
   # return the plot
   return(p)
}




#### Set the working directory to the folder containing your rooted tree
setwd("") 

#### Define trees to import
# change pattern as required and make sure the files are in the working directory or change the first argument of list.files
# it is fine if this just targets one tree, your list will just contain one tree
trees <- list.files(".", pattern = "Alltree", full.names = T)

#### Define titles for plots for each tree and store this as the names of the above list
# In this example, we do it by simplifying the tree names, but we could change completely
#names(trees) <- gsub("_trees_BP10_SpeciesTree_annotQ_rooted2.tre", "", trees) # Change dep on file name ending
#names(trees) <- gsub("./CDS_L_alM_r_o_CI85_T_o_g_", "", names(trees)) # Change dep on file name beginning
names(trees) <- c("rooted", "unrooted")

#### Run the function on all trees (using a loop)
# The plots retuned by each iteration of the loop/function will be stored in a list
# The function also makes single plots for each tree and directly exports them in separate pdfs

tree_plots <- vector(mode="list", length=length(trees))

for (x in 1:length(tree_plots)) {
  p <- plot_astral(intree=trees[[x]], intree_name = names(trees)[x])
  tree_plots[[x]] <- p
}

#### Export all plots to a single pdf (unnecessary if just one tree as the plot will have been exported above already)
# change size and file name as required (eg for one tree with 200 taxa: 15, 45; with 450 taxa: 10,65)

pdf("My_trees_PP1_QSpies.pdf", 20, 10) # change name as you wish
grid.arrange(tree_plots[[1]], tree_plots[[2]], nrow=1) # change/add numbers as needed, depending on the number of trees and rows wanted
dev.off()




############### Notes #######################################################################################################

# Could do exactly the same pie charts with posterior probabilities, just replace "q1" by "pp1" etc. in the QS_calc function
# If want to plot mirror trees for just 2 trees, check plot_Astral_trees_v2.R
# If want to plot QS to see their values, check plot_Astral_trees_v2.R


# pies with q1 etc give the quartet support: percentage of quartets agreeing: 
# with the branch (red), 
# with the second alternative RS|LO (cyan), 
# and with the last alternative RO|LS (gray).

# see Astral tutorial github page for more details about branch annotations
