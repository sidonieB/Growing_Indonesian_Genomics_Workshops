# plotting PCA from covariant matrices derived from ANGSD

#load dependencies
library(ggplot2)
library(ggfortify)
library(factoextra)
library(RColorBrewer)

# Define data files

covariance_matrix <- "pcangsd015_30Atl_NInd23_NUC.cov"
sample_info <- "sample_info_simplified_06March2024.txt"


# load covariance matrix and format it

cov = as.matrix(read.table(covariance_matrix))
cov = as.data.frame(cov)

# load table with pop info and transfer this info to the covariance matrix

ID.tab = read.table(sample_info, header = T, sep="\t")
cov.ID = cov
cov.ID$ID = ID.tab$ID
cov.ID$Species = ID.tab$Species
cov.ID$Origin = ID.tab$Origin
rownames(cov.ID) = ID.tab$ID

# Decide what to color on the pca
color_var <- cov.ID$Origin
#Decide what to label on the pca
label_var <- cov.ID$ID


# Plot the variation explained by the PCA components

res.pca = prcomp(cov)
pdf("axis_explained_variation.pdf", 15, 10)
var = fviz_eig(res.pca, addlabels = TRUE, ylim = c(0, 100))
ggpubr::ggpar(var,
              title = "Principal Component Analysis - axis variance",
              subtitle = "my subtitle",
              caption = "Source: factoextra",
              xlab = "Dimensions", ylab = "% of explained variation",
              #legend.title = "Species", legend.position = "top",
              ggtheme = theme_minimal(), palette = c("dodgerblue2") #, "#F1932D", "#E8601C", "#DC050C") 
)
dev.off()


# Plot PCA components 1 and 2

var = fviz_eig(res.pca, addlabels = TRUE, ylim = c(0, 100))
ggpubr::ggpar(var,
              title = "Principal Component Analysis - axis variance",
              subtitle = "subtitles",
              caption = "Source: factoextra",
              xlab = "Dimensions", ylab = "% of explained variation",
              #legend.title = "Species", legend.position = "top",
              ggtheme = theme_minimal(), palette = c("dodgerblue2") #, "#F1932D", "#E8601C", "#DC050C") 
)

p = fviz_pca_ind(res.pca,
                 col.ind = color_var, # Color by the quality of representation
                 geom.ind = "point", # show points only (but not "text") testing this
                 pointshape = 19, 
                 pointsize = 2,
                 legend.title = "Species",
                 #palette = c("dodgerblue2", "#E31A1C", "green4", "#6A3D9A", "#FF7F00", "black", "gold1", "skyblue2", "#FB9A99", "palegreen2", "#CAB2D6"),
                 #addEllipses = TRUE,
                 #habillage = cov.ID$Spp,
                 #geom.ind = "point",
                 axes = c(1, 2), # choose PCs to plot,
                 repel = TRUE,     # Avoid text overlapping
                 mean.point=F      # remove centroid for sp
) +
  ggrepel::geom_text_repel(aes(label = label_var))

ggsave("pca12.pdf", p, width=10, height=8)



# Plot PCA components 2 and 3

p2 = fviz_pca_ind(res.pca,
                 col.ind = color_var, # Color by the quality of representation
                 geom.ind = "point", # show points only (but not "text") testing this
                 pointshape = 19, 
                 pointsize = 2,
                 legend.title = "Species",
                 #palette = c("dodgerblue2", "#E31A1C", "green4", "#6A3D9A", "#FF7F00", "black", "gold1", "skyblue2", "#FB9A99", "palegreen2", "#CAB2D6"),
                 #addEllipses = TRUE,
                 #habillage = cov.ID$Spp,
                 #geom.ind = "point",
                 axes = c(2, 3), # choose PCs to plot,
                 repel = TRUE,     # Avoid text overlapping
                 mean.point=F      # remove centroid for sp
) +
  ggrepel::geom_text_repel(aes(label = label_var)) # change label from nrs to ID and repel

ggsave("pca23.pdf", p2, width=10, height=8)


