library(dplyr)
library(stringr)
library(tidyr)
library(ggplot2)
library(gridExtra)

### Define the data to use

# provide the name of your original input file
infile="NGSadmix.015_ana.4_S42_NInd32_"

# provide the name of the likelihoods file
likfile="all_lik"

# provide path to qopt files
qopt_path <- "qopt_files/"

# provide the name of the sample info table
# IMPORTANT: the samples in this table should be listed 
# in the same order as in the bam files list used to run angsd!
samples_tab <- "NGSadmix015/data/sample_info/sample_info_simplified_S42_06March2024.txt"

# provide the K values
K_v <- c(1,2,3,4,5,6,7,8)


### Format the data

# Read the file containing the likelihoods
lik <- read.table(likfile, sep="")

# simplify the lik table
lik2 <- lik %>%
  mutate(V1 = str_replace(V1, infile, "")) %>%
  mutate(V1 = str_replace(V1, ".log:best", "")) %>%
  mutate(V2 = str_replace(V2, "like=","")) %>%
  select(V1,V2) %>%
  separate(V1, into=c("K", "run"), sep = "_") %>% # separate by _ into two cols
  mutate(run = str_replace(run, "Run","")) %>% # rm word "run" 
  mutate(K = str_replace(K, "K","")) %>%
  arrange(as.numeric(K))

# save the simplified table
write.table(lik2, "Summary_Lk.txt", quote=F, row.names = F)

# plot the likelihoods
ggplot(lik2, aes(as.numeric(K), as.numeric(V2))) +
  geom_point() +
  theme_classic() +
  xlab("K") + ylab("Likelihood") +
  theme(aspect.ratio=1)
ggsave("likelihoods_per_K.pdf")

# Retrieve the best run for each K value
best_run <- lik2 %>% group_by(K) %>% summarise(countLk=max(run), bestRun=run[which.max(V2)])

allK <- read.table(paste(qopt_path, infile, "K1_Run", best_run$bestRun[1], ".qopt", sep=""))

for (k in 2:length(best_run$K)) {
  
  best <- best_run$bestRun[k]
  Knum <- paste("K",best_run$K[k],sep="")
  tab <- read.table(paste(qopt_path, infile, Knum, "_Run", best, ".qopt", sep=""))
  allK <- bind_cols(allK, tab)
}

# Remove first column
allK <- allK[,-1]

# Rename columns
if (length(K_v) != 8) {
  print("YOU NEED TO CHANGE THE COLNAMES BELOW IF YOU HAVE A DIFFERENT NUMBER OF K THAN 8")
}

colnames(allK) <- c("K2_1", "K2_2", 
                    "K3_1", "K3_2", "K3_3", 
                    "K4_1", "K4_2", "K4_3", "K4_4", 
                    "K5_1", "K5_2", "K5_3", "K5_4", "K5_5",
                    "K6_1", "K6_2", "K6_3", "K6_4", "K6_5", "K6_6",
                    "K7_1", "K7_2", "K7_3", "K7_4", "K7_5", "K7_6","K7_7",
                    "K8_1", "K8_2", "K8_3", "K8_4", "K8_5", "K8_6","K8_7","K8_8")


# Import sample info
sample_info <- read.table(samples_tab, sep = "\t", header = T)

# Merge sample info and K table
allK2 <- bind_cols(sample_info, allK)

# Export table in case needed
write.table(allK2, "NGSadmix_all_K_with_Sample_info.txt" , sep="\t",  row.names=F, quote=F)



#### plot the population clusters for each K

# remove K1 from the vector of K if it exists

if( 1 %in% K_v) {
  K_v_2 <- K_v[-which(K_v == 1)]
} else {
  K_v_2 <- K_v
}

# create the plots (make sure to run the all the below everytime you run the loop)

K_plots <- vector(mode="list", length=length(K_v_2))

num_vars <- length(names(sample_info))

z <- 0

for (x in 1:length(K_v_2)) {
  
Klen <- K_v_2[x]
Kcol1 <- num_vars + 1 + z
Kcol2 <- num_vars + Klen + z

z <- z + Klen

# Change variable ids and column numbers corresponding to them as needed

anc_K <- reshape2::melt(allK2[,c(1,2,Kcol1:Kcol2)], id.vars=c("ID", "Origin"), variable.name="K", value.name="Ancestry")

p <- ggplot(anc_K, aes(x=ID, y=Ancestry, fill=K)) +
  geom_bar(stat="identity", position="stack") +
  #scale_fill_manual(values=c("#56B4E9","#0072B2")) + # light blue - dark blue
  geom_col(color = "gray", size = 0.1) +
  theme_minimal() +
  scale_y_continuous(expand = c(0, 0)) +
  scale_x_discrete(expand = expansion(add = 1), position="top") +
  theme(axis.text.x = element_text(size=5, angle=90), legend.position = "none",
        axis.title.x = element_blank()) +
  ylab(paste("K = ", Klen, sep=""))+
  facet_grid(. ~ Origin, switch = "x", space="free", scales="free")

K_plots[[x]] <- p

}

# plot all the plots in a single pdf
pdf("Admix_plots.pdf", 10, 20) # change name as you wish
grid.arrange(K_plots[[1]], K_plots[[2]], K_plots[[3]], 
             K_plots[[4]], K_plots[[5]], K_plots[[6]], 
             K_plots[[7]], nrow=7) # change/add numbers as needed, depending on the number of plots and rows wanted
dev.off()
